# COPAS Academy

Plateforme de formation à distance de COPAS pour les professionnels des collectivités et des associations,
conçue pour produire les preuves attendues par le référentiel Qualiopi (décret n° 2026-728, guide de lecture V10).

Refonte complète de l'ancienne application `copas-mooc` (Rails 6.0 / Ruby 2.7, sans maintenance de sécurité depuis 2023).

## Pile technique

| | |
|---|---|
| Langage, framework | Ruby 3.4, Rails 8.1 |
| Base de données | PostgreSQL (une seule base : données, file de tâches, cache, Action Cable) |
| Interface | Hotwire (Turbo + Stimulus), Tailwind CSS 4, importmap (pas de Node.js en production) |
| Comptes | Devise 5 (confirmation, verrouillage après 8 échecs, expiration de session, mots de passe de 12 caractères minimum) |
| Autorisations | Pundit (rôles apprenant, formateur, administrateur, auditeur en lecture seule) |
| Tâches de fond | Solid Queue (relances d'inactivité, questionnaires à froid) |
| Fichiers | Active Storage sur stockage objet S3 hébergé en France (Scaleway ou OVHcloud) |
| Documents PDF | Prawn (attestation de fin de formation, relevé de participation) |
| Hébergement conseillé | Scalingo (PaaS français, déploiement par `git push`, comme Heroku) |

## Démarrer en local

Prérequis : Ruby 3.4.12 (rbenv, asdf ou mise), PostgreSQL 14 ou plus.

```bash
bundle install
bin/rails db:prepare      # crée la base, joue les migrations et charge les données de démonstration
bin/dev                   # serveur web et compilation Tailwind en continu → http://localhost:3000
```

Comptes de démonstration (mot de passe `CopasAcademy2026`, modifiable avec `SEED_PASSWORD`) :

| Compte | Rôle |
|---|---|
| admin@copas.coop | Administrateur, référent signalements |
| formatrice@copas.coop | Formatrice, référente pédagogique de la formation exemple |
| auditeur@copas.coop | Auditeur Qualiopi, consultation seule |
| apprenant@exemple.fr | Apprenant, avec une demande d'inscription en attente |

Les courriels envoyés en développement sont visibles sur http://localhost:3000/letter_opener.

Tests et contrôles de sécurité :

```bash
bin/rails test             # modèles, parcours Qualiopi et non-régression des failles de l'ancienne version
bin/brakeman               # analyse statique de sécurité
bin/bundler-audit          # vulnérabilités connues des dépendances
```

## Déployer sur Scalingo (hébergement en France)

1. Créer l'application sur Scalingo (région `osc-fr1`) et ajouter l'addon PostgreSQL.
2. Créer un bucket chez Scaleway Object Storage (région `fr-par`) ou OVHcloud, et une clé d'accès dédiée.
3. Définir les variables d'environnement :

| Variable | Exemple / rôle |
|---|---|
| `SECRET_KEY_BASE` | générée par `bin/rails secret` |
| `APP_HOST` | `academy.copas.coop` |
| `S3_BUCKET`, `S3_ACCESS_KEY_ID`, `S3_SECRET_ACCESS_KEY` | accès au stockage objet |
| `S3_ENDPOINT`, `S3_REGION` | facultatifs (Scaleway Paris par défaut). Pour OVH : `ACTIVE_STORAGE_SERVICE=ovh` |
| `SMTP_ADDRESS`, `SMTP_PORT`, `SMTP_USERNAME`, `SMTP_PASSWORD` | envoi des courriels (Brevo, Scaleway TEM, Mailjet…) |
| `MAIL_FROM`, `TEAM_EMAIL` | expéditeur et adresse de l'équipe formation |
| `ORG_NAME`, `ORG_LEGAL_FORM`, `ORG_ADDRESS`, `ORG_SIRET`, `ORG_NDA`, `ORG_SIGNATORY_NAME`, `ORG_SIGNATORY_TITLE` | mentions légales des attestations |
| `ADMIN_EMAIL`, `SEED_PASSWORD` | premier compte administrateur créé par `db:seed` |

4. Déployer : `git push scalingo main`. Le `Procfile` lance le serveur web (`web`), les tâches de fond (`worker`) et les migrations (`postdeploy`).
5. Une seule fois : `scalingo run bin/rails db:seed` pour créer les pages institutionnelles et le compte administrateur.
6. Ajouter le domaine et activer le certificat TLS dans le tableau de bord Scalingo.

Le conteneur `worker` est indispensable : il envoie chaque matin les relances d'inactivité et les alertes de décrochage (indicateur 19), et les questionnaires à froid à J+90 (indicateur 30). Voir `config/recurring.yml`.

## Reprendre les données de l'ancienne plateforme

```bash
LEGACY_DATABASE_URL=postgres://… bin/rails legacy:import
# avec les fichiers (vidéos, images) si vous avez une copie de l'ancien dossier storage/ :
LEGACY_DATABASE_URL=postgres://… LEGACY_STORAGE_PATH=/chemin/storage bin/rails legacy:import
```

L'URL de l'ancienne base Heroku s'obtient avec `heroku config:get DATABASE_URL -a copas-formation`.
Les mots de passe sont conservés. Les ateliers sont repris **en brouillon**, avec leurs leçons, leur QCM (qui devient l'évaluation finale) et leurs résultats attendus (qui deviennent des objectifs à critériser). Il faut compléter chaque fiche avant de la publier. L'import peut être relancé sans créer de doublons.

Attention : l'ancienne application stockait les fichiers sur le disque du serveur Heroku, qui est effacé à chaque redémarrage. Les vidéos téléversées en production sont donc probablement perdues et devront être remises en ligne.

## Parcours apprenant et preuves Qualiopi

Chaque étape est horodatée dans un journal en ajout seul (`activity_events`). L'attestation, le relevé de participation et les indicateurs publics sont générés à partir de ces mêmes données, ce qui garantit la cohérence documentaire.

| Étape | Indicateur | Où, dans l'app |
|---|---|---|
| Fiche formation complète, datée, publiée avant inscription | 1 | La publication est bloquée tant qu'un champ obligatoire manque ; la date de mise à jour est automatique |
| Indicateurs de résultats avec base et formule | 2 | Fiche formation (publiés à partir de 5 apprenants) et Gestion › Formation › Indicateurs |
| Recueil nominatif des besoins, bloquant, avec volet employeur | 4 | Formulaire de demande d'inscription |
| Synthèse de l'analyse du besoin par l'équipe | 4 | Dossier apprenant : la validation est impossible sans cette synthèse |
| Objectifs évaluables, avec critère | 5 | Fiche formation, rattachés aux questions d'évaluation |
| Déroulé avec durée moyenne de chaque activité | 6, D6313-3-1 | Programme public, livret d'accueil |
| Positionnement d'entrée et compétences numériques, avec décision tracée | 8 | Test d'entrée, décision automatique selon un seuil, ajustable et motivée par l'équipe |
| Livret d'accueil, règlement, CGU, avec accusé de lecture | 9 | Étape obligatoire avant le positionnement |
| Accompagnement et adaptations tracés | 10 | Assistance (questions pédagogiques et techniques), relances, notes de positionnement |
| Quiz de module et évaluation finale critériée par objectif | 11, D6313-3-1 | Résultats par objectif, copie corrigée |
| Prévention des ruptures, signalements de violences, harcèlement ou discrimination | 12 | Relances, abandon avec cause, signalement confidentiel lu par le seul référent désigné |
| Compte observateur pour l'auditeur | 17 | Rôle « auditeur » : tout l'espace de gestion en lecture seule |
| Effectivité du suivi à distance | 19 | Temps actif mesuré, progression, relance automatique après N jours, alerte de décrochage au référent, tableau de suivi |
| Référent pédagogique par formation | 19 | Champ de la fiche formation |
| Appréciations à chaud et à froid, distinctes de l'évaluation | 30 | Questionnaire de fin de parcours, questionnaire à J+90 envoyé automatiquement |
| Réclamations, difficultés, aléas : accusé de réception, réponse, registre | 31 | Formulaire public, registre dans l'espace de gestion |
| Actions d'amélioration issues des réclamations | 32 | Champ « action d'amélioration » de chaque réclamation |
| Attestation de fin de formation avec résultats de l'évaluation | L6353-1 | PDF généré à la fin du parcours |
| Relevé de participation (dossier de preuve) | D6313-3-1 | PDF par apprenant dans l'espace de gestion |

## Formations sur site (sessions intra)

Une formation peut être « à distance » ou « sur site ». Une formation sur site se décline en **sessions** organisées pour une structure cliente (intra) : dates et demi-journées, lieu, formateur et mode d'émargement.

1. **Demande** : sur la fiche publique, la structure clique sur « Demander cette formation pour ma structure » et décrit son besoin. C'est l'analyse du besoin du commanditaire (ind. 4) ; elle apparaît dans Gestion › Demandes des structures.
2. **Session** : depuis la demande, « Créer la session » pré-remplit la formation et la structure. On choisit les demi-journées, le lieu (adresse, accès, accessibilité, ind. 17), le formateur et le mode d'émargement :
   - **photo de la feuille signée** (par défaut) : l'app génère la feuille pré-remplie, le formateur coche les présences et la photographie (dépôt possible jusqu'à 7 jours après) ;
   - **signature au doigt** ou **confirmation « Je suis présent »** : chaque participant signe sur son téléphone (QR code affiché par le formateur) ou sur la tablette du formateur avec son code personnel à 4 chiffres. La signature n'est possible que pendant la demi-journée (avec 30 minutes de marge).
3. **Participants** : saisis un par un ou importés en CSV (`prenom;nom;email;fonction`). Chacun reçoit une invitation (lien valable 14 jours) pour créer son mot de passe, compléter son recueil des besoins, lire le livret d'accueil et passer le positionnement.
4. **Convocations** envoyées automatiquement à J-7, rappel à J-1 (`ConvocationJob`), avec lieu, horaires, accès et code personnel.
5. **Le jour J** : écran « Aujourd'hui » du formateur (téléphone ou tablette). Il ouvre l'émargement, suit les signatures en direct, note absences et retards, signe et clôture la demi-journée. Une fois clôturée, la feuille est figée ; toute correction exige un motif, tracé dans le journal.
6. **Après** : évaluation finale (ouverte dès le premier jour de la session), satisfaction des participants, questionnaire envoyé au commanditaire par lien sécurisé (ind. 30). L'attestation de fin de formation (heures suivies) est disponible dès la clôture de la dernière demi-journée. Les certificats de réalisation et les feuilles d'émargement signées se génèrent en PDF depuis la fiche de la session.
7. **Supports** : déposés sur la session et téléchargeables par les participants pendant 1 an.

### Ce qui reste à faire par COPAS (hors code)

- Rédiger les pages institutionnelles créées par `db:seed`, marquées « [À compléter] » : livret d'accueil, règlement intérieur, CGU, référents, accessibilité, procédure violences, assistance, données personnelles, mentions légales.
- Désigner nominativement les référents : pédagogique, administratif, handicap, signalements.
- Renseigner les mentions légales des attestations (`ORG_*`).
- Fixer la durée de conservation des données selon les financeurs, tenir le registre des traitements et signer un contrat de sous-traitance RGPD avec l'hébergeur et le fournisseur de stockage.
- Les indicateurs qui reposent sur l'organisation de COPAS : veilles (23 à 25), réseau handicap (26), compétences des intervenants (21 et 22), analyse des risques (32).

### Lots suivants envisagés

- Archivage versionné de chaque fiche publiée (preuve de l'information diffusée à une date donnée, ind. 1).
- Sessions inter (agents de structures différentes) publiées au catalogue avec inscription individuelle.
- Grille d'observation par objectif remplie par le formateur, bilan formateur, formations mixtes (en ligne + salle).
- Classes virtuelles avec émargement électronique horodaté par demi-journée.
- Questionnaires adressés à l'employeur et aux intervenants (ind. 30).
- Vérifier la mise en page du certificat de réalisation avec le dernier modèle ministériel et les exigences des OPCO.
- Registre de veille relié aux versions des modules (ind. 23 à 25) et cartographie des risques (ind. 32).
- Export du dossier d'audit par échantillon d'apprenants.

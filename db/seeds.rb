# Données initiales : pages institutionnelles (modèles à relire), comptes de démonstration
# en développement, et une formation exemple complète.
# Usage : bin/rails db:seed  (idempotent)

puts "Pages institutionnelles…"

A_COMPLETER = "<p><strong>[À compléter par COPAS avant la mise en ligne]</strong></p>".freeze

pages = {
  "livret-accueil" => <<~HTML,
    #{A_COMPLETER}
    <h2>Bienvenue</h2>
    <p>Ce livret présente le fonctionnement de COPAS Academy, l'équipe qui vous accompagne et vos interlocuteurs. Merci de le lire avant de commencer.</p>
    <h2>Comment se déroule votre formation</h2>
    <ul>
      <li>Vous suivez les modules à votre rythme, depuis un ordinateur, une tablette ou un téléphone récent.</li>
      <li>Chaque module indique sa durée moyenne. Un quiz permet de vérifier ce que vous avez retenu.</li>
      <li>Une évaluation finale notée mesure l'atteinte des objectifs. Son résultat figure sur votre attestation.</li>
      <li>Nous mesurons votre progression et le temps passé sur la plateforme pour attester de votre participation auprès de votre employeur ou de votre financeur.</li>
    </ul>
    <h2>Assistance</h2>
    <p>Questions pédagogiques et techniques : rubrique « Assistance » de votre espace, ou par courriel. Réponse sous 2 jours ouvrés.</p>
    <h2>Vos interlocuteurs</h2>
    <p>Référent pédagogique, référent administratif, référent handicap, référent signalements : voir la page « Équipe et référents ».</p>
    <h2>Vos droits</h2>
    <p>Vous pouvez à tout moment faire une réclamation ou signaler une situation de violence, de harcèlement ou de discrimination depuis le pied de page.</p>
  HTML
  "reglement-interieur" => <<~HTML,
    #{A_COMPLETER}
    <p>Règlement intérieur établi en application des articles L6352-3 et suivants et R6352-1 et suivants du Code du travail.</p>
    <h2>Article 1 – Objet et champ d'application</h2><p>…</p>
    <h2>Article 2 – Assiduité en formation à distance</h2><p>L'apprenant s'engage à suivre les modules et à réaliser les évaluations prévues. Le temps de connexion et la progression sont enregistrés…</p>
    <h2>Article 3 – Règles d'usage de la plateforme et des espaces d'échange</h2><p>…</p>
    <h2>Article 4 – Prévention des violences, du harcèlement et des discriminations</h2><p>…</p>
    <h2>Article 5 – Sanctions et procédure disciplinaire</h2><p>…</p>
  HTML
  "cgu" => <<~HTML,
    #{A_COMPLETER}
    <h2>Inscription sur convention ou devis</h2>
    <p>Les inscriptions sont réalisées sur demande. Après étude de la demande et de vos besoins, COPAS adresse à votre employeur une convention de formation ou un devis. L'accès à la formation est ouvert à réception de la convention signée.</p>
    <h2>Conditions d'accès et durée d'accès à la plateforme</h2><p>…</p>
    <h2>Tarifs, facturation et annulation</h2><p>…</p>
    <h2>Propriété intellectuelle</h2><p>…</p>
  HTML
  "referents" => <<~HTML,
    #{A_COMPLETER}
    <ul>
      <li><strong>Référent pédagogique :</strong> Prénom Nom – courriel</li>
      <li><strong>Référent administratif :</strong> Prénom Nom – courriel</li>
      <li><strong>Référent handicap :</strong> Prénom Nom – courriel</li>
      <li><strong>Référent chargé des signalements (violences, harcèlement, discriminations) :</strong> Prénom Nom – courriel</li>
      <li><strong>Référent technique (plateforme) :</strong> Prénom Nom – courriel</li>
    </ul>
  HTML
  "accessibilite" => <<~HTML,
    #{A_COMPLETER}
    <p>Nos formations sont conçues pour être accessibles : textes lisibles et contrastés, navigation au clavier, vidéos sous-titrées et transcrites, documents téléchargeables.</p>
    <p>Si vous avez besoin d'un aménagement, cochez la case prévue lors de votre demande d'inscription ou écrivez au référent handicap. Nous étudions ensemble les adaptations possibles, avec l'appui de nos partenaires (Agefiph, FIPHFP, Cap emploi, Ressource Handicap Formation).</p>
    <p>Déclaration d'accessibilité numérique : la plateforme vise la conformité RGAA 4.1 (niveau AA). Audit à réaliser.</p>
  HTML
  "prevention-violences" => <<~HTML,
    #{A_COMPLETER}
    <p>COPAS ne tolère aucune violence, notamment sexiste ou sexuelle, aucun harcèlement et aucune discrimination, que ce soit dans les échanges sur la plateforme, en classe virtuelle ou en dehors.</p>
    <h2>Comment signaler</h2>
    <p>Utilisez le formulaire « Signaler une situation de violence ou de harcèlement » en pied de page. Votre signalement n'est lu que par le référent désigné. Vous recevez un accusé de réception immédiat.</p>
    <h2>Comment nous traitons votre signalement</h2><p>…</p>
    <h2>Numéros utiles</h2><p>17 ou 112 en cas de danger immédiat. 3919 : Violences Femmes Info. 119 : enfance en danger.</p>
  HTML
  "assistance" => <<~HTML,
    #{A_COMPLETER}
    <ul>
      <li><strong>Assistance pédagogique :</strong> rubrique Assistance de votre espace – réponse sous 2 jours ouvrés.</li>
      <li><strong>Assistance technique :</strong> rubrique Assistance ou courriel – du lundi au vendredi, 9 h – 17 h, réponse sous 1 jour ouvré.</li>
      <li><strong>Configuration conseillée :</strong> navigateur récent (Firefox, Chrome, Edge, Safari), connexion internet, haut-parleurs ou écouteurs.</li>
    </ul>
  HTML
  "confidentialite" => <<~HTML,
    #{A_COMPLETER}
    <p>Responsable de traitement : COPAS. Finalités : gestion des inscriptions et des parcours de formation, preuve de la réalisation des formations auprès des financeurs, amélioration de la qualité (Qualiopi).</p>
    <p>Données suivies : progression par module, temps actif sur la plateforme, résultats des évaluations, échanges avec l'équipe. Aucune adresse IP n'est conservée dans le suivi pédagogique.</p>
    <p>Hébergement : en France (application, base de données et fichiers).</p>
    <p>Durée de conservation : … (alignée sur les exigences des financeurs).</p>
    <p>Vos droits : accès, rectification, effacement, limitation, opposition – écrire à … . Réclamation possible auprès de la CNIL.</p>
  HTML
  "mentions-legales" => "#{A_COMPLETER}<p>Éditeur : COPAS, … – Hébergeur : Scalingo SAS, Strasbourg, France.</p>",
  "indicateurs" => <<~HTML
    <p>Pour chaque formation, nous publions sur sa fiche des indicateurs calculés automatiquement à partir des parcours réels des 12 derniers mois : nombre d'apprenants, taux de réalisation, taux d'abandon, taux de réussite à l'évaluation finale, satisfaction et recommandation.</p>
    <p>Chaque indicateur est accompagné de sa base (nombre de personnes concernées) et de son mode de calcul.</p>
  HTML
}

pages.each do |slug, body|
  page = Page.find_or_initialize_by(slug: slug)
  next if page.persisted?

  page.update!(title: Page::SLUGS.fetch(slug), body: body)
end

puts "Comptes…"

def seed_user(email, attrs)
  User.find_or_initialize_by(email: email).tap do |u|
    next if u.persisted?

    u.assign_attributes(attrs.merge(password: ENV.fetch("SEED_PASSWORD", "CopasAcademy2026"), terms_accepted_at: Time.current))
    u.skip_confirmation!
    u.save!
  end
end

admin = seed_user(ENV.fetch("ADMIN_EMAIL", "admin@copas.coop"), first_name: "Admin", last_name: "COPAS", role: :admin, reports_referent: true)

if Rails.env.development? || ENV["SEED_DEMO"] == "1"
  trainer = seed_user("formatrice@copas.coop", first_name: "Claire", last_name: "Martin", role: :trainer, job_title: "Formatrice, chargée d'études")
  seed_user("auditeur@copas.coop", first_name: "Compte", last_name: "Auditeur", role: :auditor)
  learner = seed_user("apprenant@exemple.fr", first_name: "Karim", last_name: "Benali", role: :learner,
                      job_title: "Conseiller en économie sociale et familiale", organization_name: "Ville de Roubaix", organization_type: :collectivite)

  puts "Formation exemple…"
  course = Course.find_or_initialize_by(slug: "prevention-impayes-logement-social")
  if course.new_record?
    course.assign_attributes(
      title: "Prévenir les impayés de loyer dans le logement social",
      subtitle: "Repérer tôt, mobiliser les bons dispositifs, accompagner le ménage",
      category: "Logement social",
      level: :initiation,
      modality: :asynchronous,
      summary: "Une formation courte pour les professionnels qui accompagnent des locataires du parc social : repérer les signaux d'alerte, connaître les aides (FSL, APL, plan d'apurement) et coordonner l'action avec le bailleur et les partenaires.",
      target_audience: "Travailleurs sociaux, conseillers en économie sociale et familiale, chargés de gestion locative et chargés de précontentieux de bailleurs sociaux, agents de CCAS.",
      prerequisites: "Aucun prérequis.",
      duration_hours: 7,
      duration_details: "À réaliser sur 3 semaines maximum",
      access_delay: "Accès sous 10 jours ouvrés après signature de la convention.",
      pedagogical_methods: "Vidéos courtes, études de cas tirées de situations réelles, fiches pratiques téléchargeables, quiz de fin de module. Échanges écrits avec la formatrice.",
      evaluation_methods: "Positionnement d'entrée (QCM), quiz à la fin de chaque module, évaluation finale notée (QCM, seuil de réussite 70 %). Résultats détaillés par objectif sur l'attestation.",
      accessibility: "Vidéos sous-titrées et transcrites, contenus lisibles au clavier et avec un lecteur d'écran. Aménagements possibles sur demande auprès du référent handicap.",
      price: 290,
      pricing_details: "Par participant, exonéré de TVA. Tarif de groupe sur devis.",
      funding_options: "Plan de développement des compétences de l'employeur (convention), OPCO pour les salariés associatifs, CNFPT pour les agents territoriaux selon le cadre défini par la collectivité.",
      digital_requirements: "Savoir naviguer sur un site internet et lire une vidéo. Ordinateur ou tablette avec haut-parleurs ou écouteurs.",
      support_details: "Questions pédagogiques via la rubrique Assistance : réponse sous 2 jours ouvrés. Assistance technique du lundi au vendredi, 9 h – 17 h.",
      contact_email: "formation@copas.coop",
      trainer: trainer, pedagogical_referent: trainer,
      status: :draft
    )
    course.save!
    [
      [ "Repérer les signaux d'alerte d'un impayé naissant", "Identifier au moins 4 signaux dans un cas pratique" ],
      [ "Mobiliser les dispositifs d'aide adaptés à la situation du ménage", "Choisir le bon dispositif dans 3 situations types" ],
      [ "Construire un plan d'apurement réaliste avec le ménage et le bailleur", "Évaluer la soutenabilité d'un plan à partir d'un budget" ]
    ].each_with_index { |(d, c), i| course.objectives.create!(position: i + 1, description: d, success_criterion: c) }

    lessons = [
      [ "Comprendre la mécanique de l'impayé", 45, "Comment une dette locative se forme, les étapes de la procédure, le rôle de chacun." ],
      [ "Les signaux d'alerte à ne pas manquer", 60, "Ruptures de ressources, changements de composition familiale, retards répétés." ],
      [ "Le Fonds de solidarité pour le logement (FSL)", 75, "Conditions, montage du dossier, articulation avec les autres aides." ],
      [ "Le plan d'apurement", 60, "Calcul du reste à vivre, négociation avec le bailleur, suivi." ]
    ]
    lessons.each_with_index do |(title, minutes, summary), i|
      lesson = course.lessons.create!(title: title, estimated_minutes: minutes, summary: summary, position: i + 1,
                                      content: "<p>#{summary}</p><p>Contenu de démonstration : remplacez-le par le contenu réel du module.</p>")
      lesson.objectives << course.objectives[[ i - 1, 0 ].max]
    end

    positioning = course.assessments.create!(kind: :positioning, title: "Positionnement d'entrée")
    final = course.assessments.create!(kind: :final, title: "Évaluation finale des acquis")

    q = ->(assessment, prompt, choices, objective = nil, explanation = nil) do
      assessment.questions.create!(prompt: prompt, objective: objective, explanation: explanation,
                                   choices_attributes: choices.each_with_index.map { |(label, ok), i| { label: label, correct: ok, position: i + 1 } })
    end
    o1, o2, o3 = course.objectives.to_a
    q.(positioning, "Avez-vous déjà accompagné un ménage en situation d'impayé de loyer ?", [ [ "Jamais", true ], [ "Quelques fois", false ], [ "Régulièrement", false ] ])
    q.(positioning, "Pour suivre la formation, vous utiliserez :", [ [ "Un ordinateur ou une tablette avec le son", true ], [ "Je ne sais pas encore", false ] ], nil, "Compétences numériques requises (ind. 8).")
    q.(positioning, "Le FSL est financé principalement par :", [ [ "Le Département", true ], [ "La CAF seule", false ], [ "Le bailleur", false ] ], o2)

    q.(final, "Quel signal doit vous alerter en priorité ?", [ [ "Deux retards de paiement consécutifs", true ], [ "Une demande de mutation", false ], [ "Un changement de banque", false ] ], o1)
    q.(final, "Une perte d'emploi récente du titulaire du bail est :", [ [ "Un signal d'alerte à traiter rapidement", true ], [ "Sans lien avec le risque d'impayé", false ] ], o1)
    q.(final, "Le FSL peut prendre en charge :", [ [ "Une partie de la dette locative", true ], [ "Les amendes", false ], [ "Les crédits à la consommation", false ] ], o2)
    q.(final, "Avant de proposer un plan d'apurement, il faut d'abord :", [ [ "Calculer le reste à vivre du ménage", true ], [ "Saisir le juge", false ], [ "Résilier le bail", false ] ], o3)

    course.update!(status: :published)
  end

  if learner.enrollments.none?
    e = course.enrollments.create!(
      user: learner, funding_type: :employer, employer_name: "Ville de Roubaix",
      needs_assessment_attributes: { job_title: learner.job_title,
                                     work_situations: "J'accompagne des locataires orientés par le CCAS après un premier impayé.",
                                     expectations: "Savoir monter un dossier FSL et négocier un plan d'apurement avec le bailleur." }
    )
    e.log!("enrollment.requested")
  end
  puts "Formation sur site exemple…"
  q ||= ->(assessment, prompt, choices, objective = nil, explanation = nil) do
    assessment.questions.create!(prompt: prompt, objective: objective, explanation: explanation,
                                 choices_attributes: choices.each_with_index.map { |(label, ok), i| { label: label, correct: ok, position: i + 1 } })
  end
  onsite = Course.find_or_initialize_by(slug: "budget-participatif-commune")
  if onsite.new_record?
    onsite.assign_attributes(
      title: "Créer et lancer un budget participatif dans sa commune",
      subtitle: "Du cadre politique au vote des habitants : une méthode pas à pas",
      category: "Participation citoyenne", delivery: :onsite, default_attendance_mode: :photo, level: :initiation,
      summary: "Une journée en salle pour concevoir un budget participatif adapté à votre commune : enveloppe et règlement, mobilisation des habitants, instruction des projets, vote et suivi.",
      target_audience: "Élus, directeurs généraux des services, chargés de mission démocratie participative.",
      prerequisites: "Aucun prérequis.", duration_hours: 7, duration_details: "Une journée ou deux demi-journées",
      access_delay: "Session organisée sous 4 à 8 semaines après signature de la convention.",
      pedagogical_methods: "Apports, études de cas de communes, atelier de construction du règlement, modèles à réutiliser.",
      evaluation_methods: "Positionnement en ligne avant la session, évaluation finale (QCM) en fin de session, seuil de réussite 70 %.",
      accessibility: "Salle accessible aux personnes à mobilité réduite ; aménagements possibles sur demande auprès du référent handicap.",
      price: nil, pricing_details: "Sur devis, pour un groupe de 6 à 15 personnes.",
      funding_options: "Budget formation de la collectivité (convention), OPCO pour les associations.",
      digital_requirements: "Un téléphone ou un ordinateur pour répondre aux questionnaires en ligne.",
      support_details: "Contact du formateur avant et après la session, réponse sous 2 jours ouvrés.",
      contact_email: "formation@copas.coop", trainer: trainer, pedagogical_referent: trainer, status: :draft
    )
    onsite.save!
    [ [ "Concevoir le cadre d'un budget participatif : enveloppe, règlement et calendrier", "Identifier les décisions à faire adopter avant le lancement" ],
     [ "Mobiliser et accompagner les habitants dans le dépôt des projets", "Choisir des modes de mobilisation adaptés" ],
     [ "Organiser l'instruction des projets, le vote et le suivi des réalisations", "Appliquer les critères de recevabilité à des projets types" ] ].each_with_index do |(d, c), i|
      onsite.objectives.create!(position: i + 1, description: d, success_criterion: c)
    end
    [ [ "Comprendre le budget participatif", 60 ], [ "Construire le cadre : enveloppe, règlement, calendrier", 120 ],
     [ "Mobiliser et accompagner les habitants", 120 ], [ "Instruire, faire voter, réaliser et rendre compte", 120 ] ].each_with_index do |(t, m), i|
      onsite.lessons.create!(title: t, estimated_minutes: m, position: i + 1)
    end
    o1, o2, o3 = onsite.objectives.to_a
    pos = onsite.assessments.create!(kind: :positioning, title: "Positionnement d'entrée")
    fin = onsite.assessments.create!(kind: :final, title: "Évaluation finale des acquis")
    q.(pos, "Un budget participatif finance en général des dépenses :", [ [ "D'investissement", true ], [ "De fonctionnement", false ], [ "Les deux sans distinction", false ] ], o1)
    q.(pos, "Pour répondre aux questionnaires, vous aurez :", [ [ "Un téléphone ou un ordinateur", true ], [ "Je ne sais pas encore", false ] ])
    q.(fin, "Avant de lancer l'appel à projets, il faut d'abord :", [ [ "Faire adopter le règlement et l'enveloppe par le conseil municipal", true ], [ "Organiser le vote", false ], [ "Désigner les lauréats", false ] ], o1)
    q.(fin, "Pour toucher les habitants les moins habitués à participer :", [ [ "Aller à leur rencontre (marchés, écoles, centres sociaux)", true ], [ "Publier sur le site de la mairie", false ] ], o2)
    q.(fin, "Un projet ne relève pas des compétences de la commune :", [ [ "Le déclarer non recevable en expliquant pourquoi", true ], [ "Le soumettre au vote quand même", false ] ], o3)
    onsite.update!(status: :published)
  end

  if CourseSession.none?
    roubaix = Organization.create!(name: "Ville de Roubaix", kind: :collectivite, contact_name: "Sophie Lefebvre", contact_email: "formation@ville-exemple.fr")
    salle = Location.create!(name: "Hôtel de ville, salle des commissions", address: "17 Grand-Place\n59100 Roubaix", capacity: 20,
                             access_details: "Métro ligne 2, station Grand-Place. Accueil au rez-de-chaussée.",
                             accessibility: "Accès de plain-pied et ascenseur, toilettes adaptées.", equipment: "Vidéoprojecteur, wifi invité")
    session = CourseSession.create!(course: onsite, organization: roubaix, location: salle, trainer: trainer, status: :confirmed,
                                    attendance_mode: :photo, funding_type: :collectivite, convention_reference: "CONV-2026-021", capacity: 12,
                                    slots_attributes: [ { date: Date.current, starts_at: "09:00", ends_at: "12:30" },
                                                       { date: Date.current, starts_at: "13:30", ends_at: "17:00" } ])
    importer = ParticipantImport.new(session, invited_by: admin)
    importer.add(first_name: "Lucie", last_name: "Moreau", email: "lucie.moreau@exemple.fr", job_title: "Chargée de mission démocratie participative")
    importer.add(first_name: "Thomas", last_name: "Durand", email: "thomas.durand@exemple.fr", job_title: "Directeur général adjoint")
    User.where(email: %w[lucie.moreau@exemple.fr thomas.durand@exemple.fr]).find_each { |u| u.update!(password: ENV.fetch("SEED_PASSWORD", "CopasAcademy2026")) }
  end
end

puts "Terminé. Connexion administrateur : #{admin.email}"

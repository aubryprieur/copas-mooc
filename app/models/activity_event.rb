# Journal horodaté en ajout seul : chaque événement du parcours y est inscrit au moment où il se produit.
# Les documents de preuve (attestation, relevé de participation) sont générés à partir de ces données.
class ActivityEvent < ApplicationRecord
  belongs_to :enrollment, optional: true
  belongs_to :user, optional: true
  belongs_to :subject, polymorphic: true, optional: true

  validates :action, :occurred_at, presence: true

  before_update { raise ActiveRecord::ReadOnlyRecord, "Le journal d'activité ne peut pas être modifié" }
  before_destroy { throw :abort unless destroyed_by_association }

  scope :chronological, -> { order(:occurred_at) }
  scope :recent_first, -> { order(occurred_at: :desc) }

  LABELS = {
    "enrollment.requested" => "Demande d'inscription et recueil des besoins",
    "needs.reviewed" => "Analyse du besoin par l'équipe pédagogique",
    "enrollment.approved" => "Inscription validée",
    "enrollment.declined" => "Demande refusée",
    "welcome.acknowledged" => "Livret d'accueil et règlement lus",
    "positioning.decided" => "Décision de positionnement",
    "positioning.overridden" => "Décision de positionnement ajustée",
    "enrollment.started" => "Début du parcours",
    "lesson.viewed" => "Module consulté",
    "lesson.completed" => "Module terminé",
    "assessment.submitted" => "Évaluation rendue",
    "reminder.sent" => "Relance envoyée",
    "support.message" => "Échange avec l'équipe pédagogique",
    "survey.submitted" => "Questionnaire de satisfaction rendu",
    "enrollment.completed" => "Parcours terminé, attestation émise",
    "enrollment.abandoned" => "Abandon enregistré",
    "enrollment.invited" => "Inscription par la structure, invitation envoyée",
    "needs.submitted" => "Recueil des besoins complété",
    "convocation.sent" => "Convocation envoyée",
    "convocation.reminder" => "Rappel de convocation envoyé",
    "attendance.opened" => "Émargement ouvert",
    "attendance.signed" => "Présence signée",
    "attendance.recorded" => "Présence saisie par le formateur",
    "attendance.corrected" => "Présence corrigée (motif tracé)",
    "attendance.closed" => "Demi-journée clôturée",
    "material.downloaded" => "Support téléchargé"
  }.freeze

  def label = LABELS.fetch(action, action)
end

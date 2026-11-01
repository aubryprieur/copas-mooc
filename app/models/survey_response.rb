# Indicateur 30 : appréciations des bénéficiaires, distinctes de l'évaluation des acquis.
class SurveyResponse < ApplicationRecord
  enum :kind, { hot: 0, cold: 1 }

  belongs_to :enrollment

  RATING_FIELDS = {
    overall_rating: "Satisfaction globale",
    content_rating: "Qualité et utilité des contenus",
    support_rating: "Accompagnement et réponses de l'équipe",
    platform_rating: "Facilité d'utilisation de la plateforme",
    objectives_rating: "Atteinte des objectifs annoncés"
  }.freeze

  validates :kind, uniqueness: { scope: :enrollment_id, message: "déjà rendu" }
  validates :overall_rating, inclusion: { in: 1..5 }
  validates :content_rating, :support_rating, :platform_rating, :objectives_rating, inclusion: { in: 1..5 }, allow_nil: true
  validates :recommend_score, inclusion: { in: 0..10 }, allow_nil: true
  validates :applied_in_practice, presence: true, if: :cold?

  after_create_commit { enrollment.log!("survey.submitted", subject: self, metadata: { kind: kind }) }
end

# Indicateur 30 : appréciation du commanditaire (structure cliente), recueillie par lien sécurisé.
class ClientSurvey < ApplicationRecord
  belongs_to :course_session

  validates :overall_rating, inclusion: { in: 1..5 }
  validates :objectives_rating, :organization_rating, :trainer_rating, inclusion: { in: 1..5 }, allow_nil: true
  validates :course_session_id, uniqueness: { message: "a déjà reçu une réponse" }
end

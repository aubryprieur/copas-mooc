# Structure cliente (collectivité, association…) : commanditaire des sessions intra.
class Organization < ApplicationRecord
  enum :kind, { collectivite: 0, association: 1, etablissement_public: 2, entreprise: 3 }, default: :collectivite

  has_many :course_sessions, dependent: :restrict_with_error
  has_many :training_requests, dependent: :nullify

  validates :name, presence: true
  validates :contact_email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true

  scope :ordered, -> { order(:name) }

  def kind_label = User::ORGANIZATION_TYPE_LABELS.fetch(kind, kind)
end

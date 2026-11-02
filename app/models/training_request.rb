# Demande d'une formation sur site par une structure (intra) : analyse du besoin du commanditaire (ind. 4).
class TrainingRequest < ApplicationRecord
  enum :status, { received: 0, quoted: 1, converted: 2, declined: 3 }, default: :received
  enum :organization_kind, { collectivite: 0, association: 1, etablissement_public: 2, entreprise: 3 }, prefix: :org

  STATUS_LABELS = { "received" => "À étudier", "quoted" => "Devis ou convention envoyé", "converted" => "Session créée", "declined" => "Sans suite" }.freeze

  belongs_to :course
  belongs_to :organization, optional: true
  has_one :course_session, dependent: :nullify

  validates :organization_name, :contact_name, :contact_email, :participants_profile, :structure_objectives, presence: true
  validates :contact_email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :structure_objectives, length: { minimum: 20, message: "doit être un peu plus détaillé (20 caractères minimum)" }
  validates :participants_count, numericality: { greater_than: 0 }, allow_nil: true

  after_create_commit do
    TrainingRequestMailer.with(request: self).acknowledged.deliver_later
    TrainingRequestMailer.with(request: self).notify_team.deliver_later
  end

  def status_label = STATUS_LABELS.fetch(status)

  def find_or_create_organization!
    organization || Organization.find_or_create_by!(name: organization_name) do |o|
      o.kind = organization_kind
      o.contact_name = contact_name
      o.contact_email = contact_email
      o.contact_phone = contact_phone
    end.tap { |o| update!(organization: o) }
  end
end

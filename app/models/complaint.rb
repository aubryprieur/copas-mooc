class Complaint < ApplicationRecord
  # complaint/difficulty/incident : ind. 31 ; report : signalement violences, harcèlement, discrimination (ind. 12)
  enum :category, { complaint: 0, difficulty: 1, incident: 2, report: 3 }
  enum :status, { received: 0, in_progress: 1, answered: 2, closed: 3 }, default: :received

  CATEGORY_LABELS = {
    "complaint" => "Réclamation",
    "difficulty" => "Difficulté rencontrée pendant la formation",
    "incident" => "Aléa ou incident (panne, accès à la plateforme…)",
    "report" => "Signalement confidentiel : violences, harcèlement ou discrimination"
  }.freeze
  STATUS_LABELS = { "received" => "Reçue", "in_progress" => "En cours de traitement", "answered" => "Réponse apportée", "closed" => "Clôturée" }.freeze

  belongs_to :user, optional: true
  belongs_to :course, optional: true
  belongs_to :handled_by, class_name: "User", optional: true

  validates :name, :email, :description, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :description, length: { minimum: 10, maximum: 10_000 }

  before_create :assign_reference
  after_create_commit :acknowledge

  scope :visible_to, ->(user) { user.reports_referent? ? all : where.not(category: :report) }
  scope :open_items, -> { where(status: %i[received in_progress]) }

  def category_label = CATEGORY_LABELS.fetch(category)
  def status_label = STATUS_LABELS.fetch(status)

  def respond!(by:, response:, improvement_action: nil, close: false)
    update!(response: response, improvement_action: improvement_action.presence || self.improvement_action,
            responded_at: Time.current, handled_by: by, status: close ? :closed : :answered,
            closed_at: (Time.current if close))
    ComplaintMailer.with(complaint: self).responded.deliver_later
  end

  private

  def assign_reference
    self.reference = "R-#{Time.current.strftime('%Y%m')}-#{SecureRandom.alphanumeric(5).upcase}"
  end

  # Accusé de réception automatique et horodaté
  def acknowledge
    update_column(:acknowledged_at, Time.current)
    ComplaintMailer.with(complaint: self).acknowledged.deliver_later
    ComplaintMailer.with(complaint: self).notify_team.deliver_later
  end
end

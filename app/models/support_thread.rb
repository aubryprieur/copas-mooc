class SupportThread < ApplicationRecord
  enum :category, { pedagogical: 0, technical: 1 }
  enum :status, { open: 0, answered: 1, closed: 2 }, default: :open

  CATEGORY_LABELS = { "pedagogical" => "Question pédagogique", "technical" => "Assistance technique" }.freeze
  STATUS_LABELS = { "open" => "En attente de réponse", "answered" => "Répondu", "closed" => "Clos" }.freeze

  belongs_to :user
  belongs_to :enrollment, optional: true
  belongs_to :lesson, optional: true
  has_many :messages, -> { order(:created_at) }, class_name: "SupportMessage", dependent: :destroy

  validates :subject, presence: true, length: { maximum: 150 }

  scope :awaiting_staff, -> { where(status: :open) }

  def category_label = CATEGORY_LABELS.fetch(category)
  def status_label = STATUS_LABELS.fetch(status)

  def response_time
    return unless first_response_at

    first_response_at - created_at
  end
end

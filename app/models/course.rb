class Course < ApplicationRecord
  enum :status, { draft: 0, published: 1, archived: 2 }, default: :draft
  enum :level, { initiation: 0, intermediaire: 1, perfectionnement: 2 }, default: :initiation
  enum :modality, { asynchronous: 0, blended: 1, synchronous: 2 }, default: :asynchronous
  # online : parcours à distance ; onsite : sessions en salle (intra), avec émargement
  enum :delivery, { online: 0, onsite: 1 }, default: :online
  enum :default_attendance_mode, { photo: 0, drawn: 1, click: 2 }, prefix: :default_attendance

  DELIVERY_LABELS = { "online" => "À distance", "onsite" => "Sur site" }.freeze

  MODALITY_LABELS = {
    "asynchronous" => "100 % à distance, à votre rythme",
    "onsite" => "En salle, dans vos locaux ou les nôtres",
    "blended" => "Mixte : à distance et classes virtuelles",
    "synchronous" => "Classes virtuelles en direct"
  }.freeze
  LEVEL_LABELS = { "initiation" => "Initiation", "intermediaire" => "Intermédiaire", "perfectionnement" => "Perfectionnement" }.freeze

  # Champs de la fiche formation exigés par l'indicateur 1 avant publication.
  REQUIRED_PUBLIC_FIELDS = %i[
    summary target_audience prerequisites duration_hours access_delay pedagogical_methods
    evaluation_methods accessibility pricing_details funding_options digital_requirements
    support_details contact_email
  ].freeze

  belongs_to :trainer, class_name: "User", optional: true
  belongs_to :pedagogical_referent, class_name: "User", optional: true

  has_many :objectives, -> { order(:position) }, dependent: :destroy, inverse_of: :course
  has_many :lessons, -> { order(:position) }, dependent: :destroy, inverse_of: :course
  has_many :assessments, -> { order(:position) }, dependent: :destroy
  has_many :enrollments, dependent: :restrict_with_error
  has_many :learners, through: :enrollments, source: :user
  has_many :survey_responses, through: :enrollments
  has_many :complaints, dependent: :nullify
  has_many :course_sessions, dependent: :restrict_with_error
  has_many :training_requests, dependent: :destroy

  has_one_attached :cover do |attachable|
    attachable.variant :card, resize_to_fill: [ 800, 450 ]
  end
  has_rich_text :description

  accepts_nested_attributes_for :objectives, allow_destroy: true, reject_if: ->(a) { a["description"].blank? }

  validates :title, presence: true, length: { maximum: 120 }
  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-z0-9-]+\z/ }
  validates :pass_threshold, :positioning_threshold, numericality: { in: 0..100 }
  validates :inactivity_reminder_days, :inactivity_alert_days, numericality: { greater_than: 0 }
  validates :contact_email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validate :public_information_complete, if: :published?

  before_validation :generate_slug
  before_save :touch_info_updated_at
  before_save -> { self.published_at ||= Time.current if published? }

  scope :catalog, -> { published.order(:title) }

  def to_param = slug

  def modality_label = onsite? ? MODALITY_LABELS["onsite"] : MODALITY_LABELS[modality]

  def positioning_assessment = assessments.find_by(kind: :positioning)
  def final_assessment = assessments.find_by(kind: :final)
  def checkpoints = assessments.checkpoint

  def total_estimated_minutes = lessons.sum(:estimated_minutes)

  def price
    price_cents && price_cents / 100.0
  end

  def price=(value)
    self.price_cents = value.present? ? (BigDecimal(value.to_s.tr(",", ".")) * 100).round : nil
  end

  def missing_public_fields
    REQUIRED_PUBLIC_FIELDS.select { |field| self[field].blank? }
  end

  def publishable_issues
    issues = missing_public_fields.map { |f| "#{Course.human_attribute_name(f)} manquant" }
    issues << "Au moins un objectif évaluable" if objectives.empty?
    issues << (onsite? ? "Au moins une séquence au déroulé" : "Au moins un module") if lessons.empty?
    issues << "Une évaluation finale avec des questions" unless final_assessment&.questions&.any?
    issues << "Un positionnement d'entrée avec des questions" unless positioning_assessment&.questions&.any?
    issues
  end

  def results_indicators(period: 12.months)
    CourseIndicators.new(self, since: period.ago)
  end

  private

  def generate_slug
    self.slug = title.to_s.parameterize if slug.blank? && title.present?
  end

  def touch_info_updated_at
    tracked = REQUIRED_PUBLIC_FIELDS.map(&:to_s) + %w[title subtitle modality price_cents recognition]
    self.info_updated_at = Time.current if new_record? || (changed & tracked).any?
  end

  def public_information_complete
    missing = missing_public_fields
    return if missing.empty?

    errors.add :base, "Fiche incomplète pour publication (indicateur 1 Qualiopi) : " +
      missing.map { |f| Course.human_attribute_name(f) }.join(", ")
  end
end

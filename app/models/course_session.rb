# Session d'une formation sur site : des demi-journées datées, dans un lieu, avec un formateur.
class CourseSession < ApplicationRecord
  enum :kind, { intra: 0, inter: 1 }, default: :intra
  enum :status, { planned: 0, confirmed: 1, completed: 2, cancelled: 3 }, default: :planned
  enum :attendance_mode, { photo: 0, drawn: 1, click: 2 }, prefix: :attendance
  enum :funding_type, { collectivite: 0, opco: 1, other_funding: 2 }, prefix: :funded_by

  STATUS_LABELS = { "planned" => "En préparation", "confirmed" => "Confirmée", "completed" => "Terminée", "cancelled" => "Annulée" }.freeze
  ATTENDANCE_LABELS = {
    "photo" => "Photo de la feuille de présence signée",
    "drawn" => "Signature au doigt sur téléphone ou tablette",
    "click" => "Confirmation « Je suis présent » sur téléphone ou tablette"
  }.freeze
  FUNDING_LABELS = { "collectivite" => "La collectivité ou la structure (convention, bon de commande)", "opco" => "OPCO", "other_funding" => "Autre" }.freeze
  MATERIALS_ACCESS = 1.year

  belongs_to :course
  belongs_to :organization, optional: true
  belongs_to :location, optional: true
  belongs_to :trainer, class_name: "User", optional: true
  belongs_to :training_request, optional: true
  has_many :slots, -> { order(:date, :starts_at) }, class_name: "SessionSlot", dependent: :destroy, inverse_of: :course_session
  has_many :enrollments, dependent: :restrict_with_error
  has_many :attendances, through: :slots
  has_one :client_survey, dependent: :destroy
  has_many_attached :materials

  accepts_nested_attributes_for :slots, allow_destroy: true, reject_if: ->(a) { a["date"].blank? }

  validates :organization, presence: { message: "(structure cliente) est obligatoire pour une session intra" }, if: :intra?
  validates :capacity, numericality: { greater_than: 0 }, allow_nil: true
  validate :at_least_one_slot

  before_validation :assign_tokens, on: :create
  before_validation -> { self.attendance_mode ||= course&.default_attendance_mode }

  scope :upcoming, -> { joins(:slots).where(session_slots: { date: Date.current.. }).distinct }
  scope :for_trainer, ->(user) { user.admin? || user.auditor? ? all : where(trainer: user) }

  def to_s = "#{course.title} – #{organization&.name || 'inter'} – #{dates_label}"
  def status_label = STATUS_LABELS.fetch(status)
  def start_date = slots.map(&:date).min
  def end_date = slots.map(&:date).max
  def total_hours = slots.sum(&:duration_hours).round(2)
  def started? = start_date.present? && start_date <= Date.current
  def all_slots_closed? = slots.any? && slots.all?(&:closed?)
  def materials_available? = end_date.nil? || Date.current <= end_date + MATERIALS_ACCESS
  def materials_available_until = end_date && end_date + MATERIALS_ACCESS

  def dates_label
    return "dates à fixer" if start_date.nil?
    return I18n.l(start_date, format: :long) if start_date == end_date

    "du #{I18n.l(start_date, format: :long)} au #{I18n.l(end_date, format: :long)}"
  end

  def participants = enrollments.where.not(status: :declined).includes(:user).sort_by { |e| e.user.last_name.to_s.downcase }

  private

  def assign_tokens
    self.reference ||= "S-#{Date.current.year}-#{SecureRandom.alphanumeric(5).upcase}"
    self.access_token ||= SecureRandom.urlsafe_base64(24)
  end

  def at_least_one_slot
    errors.add :base, "Ajoutez au moins une demi-journée (date et horaires)" if slots.reject(&:marked_for_destruction?).empty?
  end
end

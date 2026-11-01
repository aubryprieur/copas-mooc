# Demi-journée de formation : l'unité d'émargement.
class SessionSlot < ApplicationRecord
  enum :status, { planned: 0, open: 1, closed: 2 }, default: :planned

  SIGNING_MARGIN = 30.minutes
  PHOTO_UPLOAD_DELAY = 7.days

  belongs_to :course_session, inverse_of: :slots
  belongs_to :closed_by, class_name: "User", optional: true
  has_many :attendances, dependent: :destroy
  has_many_attached :sheet_photos

  validates :date, :starts_at, :ends_at, presence: true
  validate :ends_after_start

  before_validation -> { self.sign_token ||= SecureRandom.urlsafe_base64(18) }, on: :create

  delegate :course, to: :course_session

  def label = "#{I18n.l(date, format: '%A %-d %B %Y').capitalize}, #{hours_label}"
  def hours_label = "#{starts_at.strftime('%H:%M')} – #{ends_at.strftime('%H:%M')}"

  def duration_hours
    return 0 unless starts_at && ends_at

    ((ends_at - starts_at) / 3600.0).round(2)
  end

  def starts_at_time = Time.zone.local(date.year, date.month, date.day, starts_at.hour, starts_at.min)
  def ends_at_time = Time.zone.local(date.year, date.month, date.day, ends_at.hour, ends_at.min)

  # Les signatures électroniques ne sont possibles que pendant la demi-journée (avec une marge).
  def signing_window_open?(at = Time.current)
    !closed? && at.between?(starts_at_time - SIGNING_MARGIN, ends_at_time + SIGNING_MARGIN)
  end

  def photo_upload_open?(at = Time.current) = at <= ends_at_time + PHOTO_UPLOAD_DELAY
  def today? = date == Date.current

  def attendance_for(enrollment) = attendances.find_or_initialize_by(enrollment: enrollment)

  def open!(by:)
    return unless planned?

    update!(status: :open, opened_at: Time.current)
    log_for_all("attendance.opened", by)
  end

  def missing_for_close
    issues = []
    if course_session.attendance_photo?
      issues << "Déposez la photo de la feuille signée" unless sheet_photos.attached?
      undecided = course_session.participants.count { |e| attendances.find { _1.enrollment_id == e.id }.nil? || attendances.find { _1.enrollment_id == e.id }.pending? }
      issues << "Indiquez présent ou absent pour chaque participant (#{undecided} à compléter)" if undecided.positive?
    end
    issues << "Signez la demi-journée en tant que formateur" if trainer_signed_at.nil?
    issues
  end

  # Clôture : la feuille est figée ; les participants sans signature sont notés absents.
  def close!(by:)
    raise ActiveRecord::RecordInvalid.new(self) if missing_for_close.any?

    transaction do
      course_session.participants.each do |enrollment|
        attendance = attendance_for(enrollment)
        if attendance.new_record? || attendance.pending?
          attendance.update!(status: :absent, recorded_by: by)
        end
      end
      update!(status: :closed, closed_at: Time.current, closed_by: by)
    end
    log_for_all("attendance.closed", by)
    course_session.update!(status: :completed, closed_at: Time.current) if course_session.reload.all_slots_closed?
  end

  private

  def log_for_all(action, by)
    course_session.participants.each { |e| e.log!(action, user: by, subject: self, metadata: { slot: label }) }
  end

  def ends_after_start
    errors.add :ends_at, "doit être après l'heure de début" if starts_at && ends_at && ends_at <= starts_at
  end
end

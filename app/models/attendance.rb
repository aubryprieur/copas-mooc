# Présence d'un participant à une demi-journée. Toute modification après clôture exige un motif tracé.
class Attendance < ApplicationRecord
  enum :status, { pending: 0, present: 1, absent: 2, late: 3, left_early: 4 }, default: :pending
  enum :signature_method, { photo_sheet: 0, drawn: 1, click: 2, tablet: 3, trainer: 4 }, prefix: :signed_by

  STATUS_LABELS = { "pending" => "Non renseigné", "present" => "Présent", "absent" => "Absent", "late" => "Arrivé en retard", "left_early" => "Parti plus tôt" }.freeze
  METHOD_LABELS = { "photo_sheet" => "Feuille papier (photo)", "drawn" => "Signature au doigt", "click" => "Confirmation en ligne",
                    "tablet" => "Signature sur la tablette du formateur", "trainer" => "Saisie du formateur" }.freeze

  belongs_to :enrollment
  belongs_to :session_slot
  belongs_to :recorded_by, class_name: "User", optional: true

  attr_accessor :correction_reason, :corrected_by

  validates :enrollment_id, uniqueness: { scope: :session_slot_id }
  validate :correction_needs_reason, on: :update

  after_update_commit :log_correction, if: -> { correction_reason.present? }

  def attended? = present? || late? || left_early?
  def status_label = STATUS_LABELS.fetch(status)

  def hours
    return 0 unless attended?

    from = arrived_at || session_slot.starts_at
    to = left_at || session_slot.ends_at
    [ ((to - from) / 3600.0), 0 ].max.round(2)
  end

  # Signature électronique par l'apprenant lui-même pendant la demi-journée
  def sign!(method:, signature: nil)
    update!(status: :present, signature_method: method, signature: signature, signed_at: Time.current)
    enrollment.log!("attendance.signed", subject: session_slot, metadata: { method: method, slot: session_slot.label })
  end

  private

  def correction_needs_reason
    return unless session_slot.closed? && (will_save_change_to_status? || will_save_change_to_arrived_at? || will_save_change_to_left_at?)

    errors.add :base, "Indiquez le motif de la correction : la feuille de cette demi-journée est clôturée" if correction_reason.blank?
  end

  def log_correction
    enrollment.log!("attendance.corrected", user: corrected_by, subject: session_slot,
                    metadata: { slot: session_slot.label, status: status, reason: correction_reason })
  end
end

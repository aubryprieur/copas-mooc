# Émargement d'une demi-journée, côté formateur (téléphone ou tablette).
class Admin::SessionSlotsController < Admin::BaseController
  before_action :set_slot
  before_action -> { authorize @slot, :manage? }, except: %i[show]

  def show
    authorize @slot
    @participants = @session.participants
    @attendances = @slot.attendances.index_by(&:enrollment_id)
  end

  def open
    @slot.open!(by: current_user)
    redirect_to admin_session_slot_path(@slot), notice: "Émargement ouvert."
  end

  # Mode photo (ou correction en séance) : le formateur indique la présence de chacun.
  def mark
    enrollment = @session.enrollments.find(params[:enrollment_id])
    attendance = @slot.attendance_for(enrollment)
    status = params[:status].presence_in(%w[present absent late left_early]) or return head(:unprocessable_entity)
    if @slot.closed?
      return redirect_to admin_session_slot_path(@slot), alert: "Demi-journée clôturée : corrigez depuis la fiche de la session, avec un motif."
    end

    attendance.assign_attributes(status: status, recorded_by: current_user,
                                 signature_method: attendance.signature_method || (@session.attendance_photo? ? :photo_sheet : :trainer),
                                 arrived_at: params[:arrived_at].presence, left_at: params[:left_at].presence)
    attendance.save!
    enrollment.log!("attendance.recorded", user: current_user, subject: @slot, metadata: { status: status, slot: @slot.label })
    redirect_to admin_session_slot_path(@slot, anchor: "p-#{enrollment.id}")
  end

  def photo
    unless @slot.photo_upload_open?
      return redirect_to admin_session_slot_path(@slot), alert: "Le délai de dépôt de la feuille (7 jours) est dépassé : contactez l'administration."
    end

    files = Array(params[:sheet_photos]).compact_blank
    return redirect_to(admin_session_slot_path(@slot), alert: "Choisissez ou prenez une photo.") if files.empty?

    @slot.sheet_photos.attach(files)
    @slot.update!(sheet_uploaded_at: Time.current)
    redirect_to admin_session_slot_path(@slot), notice: "Photo de la feuille enregistrée."
  end

  def trainer_sign
    signature = params[:signature].to_s
    if @session.attendance_drawn? || @session.attendance_photo?
      unless signature.start_with?("data:image/png;base64,") && signature.bytesize.between?(500, 300_000)
        return redirect_to admin_session_slot_path(@slot, anchor: "cloture"), alert: "Tracez votre signature avant de valider."
      end
    end
    @slot.update!(trainer_signature: signature.presence, trainer_signed_at: Time.current)
    redirect_to admin_session_slot_path(@slot, anchor: "cloture"), notice: "Signature du formateur enregistrée."
  end

  def close
    missing = @slot.missing_for_close
    return redirect_to(admin_session_slot_path(@slot, anchor: "cloture"), alert: missing.join(" · ")) if missing.any?

    @slot.close!(by: current_user)
    redirect_to admin_session_slot_path(@slot), notice: "Demi-journée clôturée : la feuille d'émargement est figée."
  end

  # Mode tablette : l'apprenant sans smartphone signe sur l'appareil du formateur avec son code personnel.
  def tablet
    @participants = @session.participants.reject { |e| @slot.attendances.find { _1.enrollment_id == e.id }&.attended? }
  end

  def tablet_sign
    enrollment = @session.enrollments.find_by(id: params[:enrollment_id])
    unless enrollment && ActiveSupport::SecurityUtils.secure_compare(enrollment.attendance_code.to_s, params[:code].to_s)
      return redirect_to tablet_admin_session_slot_path(@slot), alert: "Code personnel incorrect."
    end
    return redirect_to(tablet_admin_session_slot_path(@slot), alert: "L'émargement n'est pas ouvert.") unless @slot.signing_window_open?

    signature = params[:signature].to_s
    if @session.attendance_drawn? && !(signature.start_with?("data:image/png;base64,") && signature.bytesize.between?(500, 300_000))
      return redirect_to tablet_admin_session_slot_path(@slot), alert: "Tracez la signature avant de valider."
    end
    @slot.attendance_for(enrollment).sign!(method: :tablet, signature: signature.presence)
    redirect_to tablet_admin_session_slot_path(@slot), notice: "Merci #{enrollment.user.first_name}, présence enregistrée."
  end

  private

  def set_slot
    @slot = SessionSlot.includes(course_session: %i[course organization location]).find(params[:id])
    @session = @slot.course_session
  end
end

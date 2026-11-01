# Émargement électronique par l'apprenant, sur son téléphone, pendant la demi-journée.
class SignaturesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_slot_and_enrollment

  def show
    @attendance = @slot.attendances.find_by(enrollment: @enrollment)
  end

  def create
    unless @slot.signing_window_open?
      return redirect_to sign_slot_path(@slot.sign_token), alert: "L'émargement de cette demi-journée n'est pas ouvert."
    end

    attendance = @slot.attendance_for(@enrollment)
    return redirect_to sign_slot_path(@slot.sign_token) if attendance.persisted? && attendance.attended?

    if @session.attendance_drawn?
      signature = params[:signature].to_s
      unless signature.start_with?("data:image/png;base64,") && signature.bytesize.between?(500, 300_000)
        return redirect_to sign_slot_path(@slot.sign_token), alert: "Tracez votre signature dans le cadre avant de valider."
      end
      attendance.sign!(method: :drawn, signature: signature)
    else
      attendance.sign!(method: :click)
    end
    redirect_to sign_slot_path(@slot.sign_token), notice: "Présence enregistrée le #{l(Time.current, format: :long)}."
  end

  private

  def set_slot_and_enrollment
    @slot = SessionSlot.includes(course_session: :course).find_by!(sign_token: params[:token])
    @session = @slot.course_session
    @enrollment = current_user.enrollments.find_by(course_session: @session)
    if @enrollment.nil?
      redirect_to dashboard_path, alert: "Vous n'êtes pas inscrit(e) à cette session."
    elsif @session.attendance_photo?
      redirect_to enrollment_path(@enrollment), notice: "Pour cette session, la présence se signe sur la feuille papier."
    end
  end
end

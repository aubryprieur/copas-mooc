# Inscription des participants d'une session intra : un par un ou par import CSV.
class Admin::ParticipantsController < Admin::BaseController
  before_action :set_session

  def new
    authorize @session, :manage_participants?
  end

  def create
    authorize @session, :manage_participants?
    importer = ParticipantImport.new(@session, invited_by: current_user)
    if params[:file].present?
      result = importer.import_csv(params[:file].read.force_encoding("UTF-8"))
      message = "#{result.created.size} participant(s) inscrit(s) et invité(s)"
      message += ", #{result.skipped.size} déjà inscrit(s)" if result.skipped.any?
      flash[:alert] = result.errors.join(" · ") if result.errors.any?
      redirect_to admin_course_session_path(@session, anchor: "participants"), notice: message
    else
      outcome = importer.add(**params.require(:participant).permit(:first_name, :last_name, :email, :job_title).to_h.symbolize_keys)
      case outcome
      when Enrollment
        redirect_to admin_course_session_path(@session, anchor: "participants"), notice: "#{outcome.user.full_name} est inscrit(e) et a reçu son invitation."
      when :already
        redirect_to new_admin_course_session_participant_path(@session), alert: "Cette personne est déjà inscrite à cette formation."
      else
        redirect_to new_admin_course_session_participant_path(@session), alert: "Inscription impossible : #{outcome}."
      end
    end
  end

  # Retrait d'un participant avant le début (sinon : enregistrer un abandon dans son dossier)
  def destroy
    authorize @session, :manage_participants?
    enrollment = @session.enrollments.find(params[:id])
    if enrollment.attendances.exists? || enrollment.attempts.exists?
      redirect_to admin_course_session_path(@session, anchor: "participants"), alert: "Ce participant a déjà des traces de formation : enregistrez plutôt un abandon dans son dossier."
    else
      enrollment.update!(status: :declined, admin_note: "Retiré de la session par la structure.")
      redirect_to admin_course_session_path(@session, anchor: "participants"), notice: "Participant retiré de la session."
    end
  end

  private

  def set_session = @session = CourseSession.find(params[:course_session_id])
end

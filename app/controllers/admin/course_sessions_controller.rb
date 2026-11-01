class Admin::CourseSessionsController < Admin::BaseController
  before_action :set_session, except: %i[index new create]

  def index
    authorize CourseSession
    scope = policy_scope(CourseSession).includes(:course, :organization, :trainer, :slots, :enrollments)
    scope = scope.where(status: params[:statut]) if params[:statut].present?
    @sessions = scope.sort_by { |s| s.start_date || Date.new(2999) }
    @sessions = @sessions.reverse if params[:statut] == "completed"
  end

  def show
    authorize @session
    @participants = @session.participants
    @slots = @session.slots.includes(:attendances)
  end

  def new
    request = TrainingRequest.find_by(id: params[:demande])
    course = request&.course || Course.onsite.find_by(slug: params[:formation])
    @session = CourseSession.new(course: course, training_request: request, trainer: course&.trainer,
                                 organization: request&.find_or_create_organization!,
                                 attendance_mode: course&.default_attendance_mode || :photo,
                                 capacity: request&.participants_count)
    2.times { @session.slots.build(starts_at: "09:00", ends_at: "12:30") }
    authorize @session
  end

  def create
    @session = CourseSession.new(session_params)
    authorize @session
    if @session.save
      @session.training_request&.update!(status: :converted)
      redirect_to admin_course_session_path(@session), notice: "Session créée. Ajoutez maintenant les participants."
    else
      @session.slots.build if @session.slots.empty?
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @session
    @session.slots.build
  end

  def update
    authorize @session
    if @session.update(session_params)
      redirect_to admin_course_session_path(@session), notice: "Session enregistrée."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @session
    @session.destroy
    redirect_to admin_course_sessions_path, notice: "Session supprimée."
  end

  def remove_material
    authorize @session, :update?
    @session.materials.find(params[:attachment_id]).purge_later
    redirect_to admin_course_session_path(@session, anchor: "supports"), notice: "Support retiré."
  end

  # Feuille d'émargement pré-remplie, à imprimer (mode photo)
  def sheet
    authorize @session, :documents?
    send_pdf AttendanceSheetPdf.new(@session, signed: false), "feuille-emargement-#{@session.reference}"
  end

  # Feuilles d'émargement remplies (signatures électroniques ou statuts saisis), pour le financeur
  def attendance_report
    authorize @session, :documents?
    send_pdf AttendanceSheetPdf.new(@session, signed: true), "emargement-#{@session.reference}"
  end

  def completion_certificates
    authorize @session, :documents?
    send_pdf CompletionCertificatePdf.new(@session), "certificats-realisation-#{@session.reference}"
  end

  def send_convocations
    authorize @session, :update?
    ConvocationJob.new.send_all(@session, reminder: false)
    @session.update!(convocations_sent_at: Time.current)
    redirect_to admin_course_session_path(@session), notice: "Convocations envoyées à #{@session.participants.size} participant(s)."
  end

  def send_client_survey
    authorize @session, :update?
    if @session.organization&.contact_email.blank?
      return redirect_to admin_course_session_path(@session), alert: "Renseignez le courriel du contact de la structure."
    end

    SessionMailer.with(session: @session).client_survey.deliver_later
    @session.update!(client_survey_sent_at: Time.current)
    redirect_to admin_course_session_path(@session), notice: "Questionnaire envoyé à #{@session.organization.contact_email}."
  end

  private

  def set_session
    @session = CourseSession.includes(:course, :organization, :location, :trainer).find(params[:id])
  end

  def send_pdf(pdf, name)
    send_data pdf.render, filename: "#{name}.pdf", type: "application/pdf", disposition: "inline"
  end

  def session_params
    permitted = params.require(:course_session).permit(
      :course_id, :organization_id, :location_id, :trainer_id, :training_request_id, :status, :attendance_mode,
      :funding_type, :convention_reference, :capacity, :adapted_program, materials: [],
      slots_attributes: %i[id date starts_at ends_at _destroy]
    )
    permitted.delete(:materials) if permitted[:materials]&.compact_blank&.empty?
    permitted
  end
end

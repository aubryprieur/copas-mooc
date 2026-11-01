class Admin::EnrollmentsController < Admin::BaseController
  before_action :set_enrollment, except: :index

  # Tableau de suivi de l'activité des apprenants (ind. 17 et 19)
  def index
    authorize Enrollment
    scope = policy_scope(Enrollment).includes(:user, :course, :lesson_progresses, course: :lessons)
    scope = scope.where(status: params[:statut]) if params[:statut].present?
    scope = scope.joins(:course).where(courses: { slug: params[:formation] }) if params[:formation].present?
    if params[:q].present?
      q = "%#{Enrollment.sanitize_sql_like(params[:q])}%"
      scope = scope.joins(:user).where("users.last_name ILIKE :q OR users.first_name ILIKE :q OR users.email ILIKE :q OR enrollments.employer_name ILIKE :q", q: q)
    end
    @pagy, @enrollments = pagy(scope.order(updated_at: :desc), limit: 30)
    @courses = Course.order(:title)
  end

  # Dossier apprenant complet : besoin, positionnement, progression, évaluations, échanges, relances, journal
  def show
    authorize @enrollment
    @events = @enrollment.activity_events.chronological.includes(:user)
    @progresses = @enrollment.lesson_progresses.index_by(&:lesson_id)
    @attempts = @enrollment.attempts.submitted.includes(:assessment).order(:submitted_at)
    @threads = @enrollment.support_threads.includes(:messages)
    @reminders = @enrollment.reminders.order(sent_at: :desc).includes(:sent_by)
  end

  def approve
    authorize @enrollment, :update?
    @enrollment.approve!(by: current_user, convention_reference: params[:convention_reference], note: params[:admin_note])
    redirect_to admin_enrollment_path(@enrollment), notice: "Inscription validée : l'apprenant a été prévenu par courriel."
  end

  def decline
    authorize @enrollment, :update?
    @enrollment.decline!(by: current_user, note: params[:admin_note].presence || "Demande non retenue.")
    redirect_to admin_enrollment_path(@enrollment), notice: "Demande refusée : l'apprenant a été prévenu."
  end

  def review_needs
    authorize @enrollment, :update?
    if params[:needs_synthesis].blank?
      return redirect_to admin_enrollment_path(@enrollment, anchor: "besoin"), alert: "Rédigez la synthèse de l'analyse du besoin."
    end

    @enrollment.review_needs!(by: current_user, synthesis: params[:needs_synthesis])
    redirect_to admin_enrollment_path(@enrollment, anchor: "besoin"), notice: "Analyse du besoin enregistrée."
  end

  def positioning
    authorize @enrollment, :update?
    decision = params[:positioning_decision].presence_in(Enrollment.positioning_decisions.keys)
    if decision.nil? || params[:positioning_note].blank?
      return redirect_to admin_enrollment_path(@enrollment, anchor: "positionnement"), alert: "Choisissez une décision et motivez-la."
    end

    @enrollment.override_positioning!(by: current_user, decision: decision, note: params[:positioning_note])
    redirect_to admin_enrollment_path(@enrollment, anchor: "positionnement"), notice: "Décision de positionnement enregistrée."
  end

  def abandon
    authorize @enrollment, :update?
    @enrollment.mark_abandoned!(by: current_user, reason: params[:abandon_reason].presence || "Non précisé")
    redirect_to admin_enrollment_path(@enrollment), notice: "Abandon enregistré avec sa cause."
  end

  # Relevé de participation (dossier de preuve) au format PDF
  def dossier
    authorize @enrollment, :export?
    send_data ParticipationReportPdf.new(@enrollment).render,
              filename: "releve-participation-#{@enrollment.user.last_name.parameterize}-#{@enrollment.course.slug}.pdf",
              type: "application/pdf", disposition: "inline"
  end

  private

  def set_enrollment
    @enrollment = Enrollment.includes(:user, :course, :needs_assessment).find(params[:enrollment_id] || params[:id])
  end
end

class Admin::CoursesController < Admin::BaseController
  before_action :set_course, except: %i[index new create]

  def index
    authorize Course
    @courses = policy_scope(Course).includes(:trainer).order(:status, :title)
  end

  def show
    authorize @course
    @lessons = @course.lessons
    @assessments = @course.assessments.includes(:questions, :lesson)
  end

  def new
    @course = Course.new(contact_email: "formation@copas.coop", prerequisites: "Aucun prérequis.")
    3.times { |i| @course.objectives.build(position: i + 1) }
    authorize @course
  end

  def create
    @course = Course.new(course_params)
    authorize @course
    if @course.save
      @course.assessments.create!(kind: :positioning, title: "Positionnement d'entrée")
      @course.assessments.create!(kind: :final, title: "Évaluation finale des acquis")
      redirect_to admin_course_path(@course), notice: "Formation créée. Ajoutez maintenant les modules et les questions."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @course
    @course.objectives.build(position: @course.objectives.size + 1)
  end

  def update
    authorize @course
    if @course.update(course_params)
      redirect_to admin_course_path(@course), notice: "Formation enregistrée."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @course
    if @course.destroy
      redirect_to admin_courses_path, notice: "Formation supprimée."
    else
      redirect_to admin_course_path(@course), alert: "Impossible de supprimer une formation qui a des inscrits : archivez-la."
    end
  end

  def indicators
    authorize @course, :show?
    @indicators = @course.results_indicators
  end

  private

  def set_course
    @course = Course.find_by!(slug: params[:course_id] || params[:id])
  end

  def course_params
    params.require(:course).permit(
      :title, :subtitle, :slug, :status, :category, :level, :summary, :description, :cover,
      :target_audience, :prerequisites, :duration_hours, :duration_details, :access_delay, :modality,
      :pedagogical_methods, :evaluation_methods, :accessibility, :price, :pricing_details, :funding_options,
      :recognition, :digital_requirements, :support_details, :contact_email, :trainer_id, :pedagogical_referent_id,
      :pass_threshold, :positioning_threshold, :inactivity_reminder_days, :inactivity_alert_days,
      :delivery, :default_attendance_mode,
      objectives_attributes: %i[id position description success_criterion _destroy]
    )
  end
end

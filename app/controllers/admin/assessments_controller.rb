class Admin::AssessmentsController < Admin::BaseController
  before_action :set_course
  before_action :set_assessment, except: %i[new create]

  def show
    authorize @assessment
    @questions = @assessment.questions.includes(:choices, :objective)
  end

  def new
    @assessment = @course.assessments.new(kind: :checkpoint, lesson_id: params[:lesson_id])
    authorize @assessment
  end

  def create
    @assessment = @course.assessments.new(assessment_params)
    authorize @assessment
    if @assessment.save
      redirect_to admin_course_assessment_path(@course, @assessment), notice: "Évaluation créée. Ajoutez les questions."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit = authorize(@assessment)

  def update
    authorize @assessment
    if @assessment.update(assessment_params)
      redirect_to admin_course_assessment_path(@course, @assessment), notice: "Évaluation enregistrée."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @assessment
    if @assessment.destroy
      redirect_to admin_course_path(@course), notice: "Évaluation supprimée."
    else
      redirect_to admin_course_assessment_path(@course, @assessment), alert: "Des copies existent : l'évaluation est conservée comme preuve."
    end
  end

  private

  def set_course = @course = Course.find_by!(slug: params[:course_id])
  def set_assessment = @assessment = @course.assessments.find(params[:id])

  def assessment_params
    params.require(:assessment).permit(:title, :instructions, :kind, :lesson_id)
  end
end

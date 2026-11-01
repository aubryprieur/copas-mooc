class Admin::QuestionsController < Admin::BaseController
  before_action :set_assessment
  before_action :set_question, only: %i[edit update destroy]

  def new
    @question = @assessment.questions.new
    4.times { |i| @question.choices.build(position: i + 1) }
    authorize @question
  end

  def create
    @question = @assessment.questions.new(question_params)
    authorize @question
    if @question.save
      redirect_to admin_course_assessment_path(@course, @assessment), notice: "Question ajoutée."
    else
      fill_choices
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @question
    fill_choices
  end

  def update
    authorize @question
    if @question.update(question_params)
      redirect_to admin_course_assessment_path(@course, @assessment), notice: "Question enregistrée."
    else
      fill_choices
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @question
    if @question.attempt_answers.exists?
      redirect_to admin_course_assessment_path(@course, @assessment), alert: "Des apprenants ont déjà répondu : la question est conservée comme preuve."
    else
      @question.destroy
      redirect_to admin_course_assessment_path(@course, @assessment), notice: "Question supprimée."
    end
  end

  private

  def set_assessment
    @course = Course.find_by!(slug: params[:course_id])
    @assessment = @course.assessments.find(params[:assessment_id])
  end

  def set_question = @question = @assessment.questions.find(params[:id])

  def fill_choices
    (4 - @question.choices.size).times { |i| @question.choices.build(position: @question.choices.size + i + 1) }
  end

  # La bonne réponse est transmise par un bouton radio commun (index du choix) puis répercutée.
  def question_params
    permitted = params.require(:question).permit(:prompt, :explanation, :objective_id,
                                                 choices_attributes: %i[id label position _destroy])
    correct_index = params.dig(:question, :correct_index).to_s
    permitted[:choices_attributes]&.each { |index, attrs| attrs[:correct] = (index.to_s == correct_index) }
    permitted
  end
end

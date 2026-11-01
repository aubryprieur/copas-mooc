class Admin::LessonsController < Admin::BaseController
  before_action :set_course
  before_action :set_lesson, except: %i[new create]

  def new
    @lesson = @course.lessons.new
    authorize @lesson
  end

  def create
    @lesson = @course.lessons.new(lesson_params)
    authorize @lesson
    if @lesson.save
      redirect_to admin_course_path(@course, anchor: "modules"), notice: "Module ajouté."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit = authorize(@lesson)

  def update
    authorize @lesson
    if @lesson.update(lesson_params)
      redirect_to admin_course_path(@course, anchor: "modules"), notice: "Module enregistré."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @lesson
    @lesson.destroy
    redirect_to admin_course_path(@course, anchor: "modules"), notice: "Module supprimé."
  end

  # Réordonnancement (glisser-déposer ou flèches)
  def move
    authorize @lesson, :update?
    lessons = @course.lessons.to_a
    index = lessons.index(@lesson)
    target = params[:direction] == "up" ? index - 1 : index + 1
    if target.between?(0, lessons.size - 1)
      lessons.insert(target, lessons.delete_at(index))
      Lesson.transaction { lessons.each_with_index { |l, i| l.update_column(:position, i + 1) } }
    end
    redirect_to admin_course_path(@course, anchor: "modules")
  end

  private

  def set_course = @course = Course.find_by!(slug: params[:course_id])
  def set_lesson = @lesson = @course.lessons.find(params[:id])

  def lesson_params
    params.require(:lesson).permit(:title, :summary, :estimated_minutes, :content, :video, :captions, resources: [], objective_ids: [])
  end
end

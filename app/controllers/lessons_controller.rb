class LessonsController < ApplicationController
  include LearnerEnrollment
  before_action :set_enrollment, :require_learning_access
  before_action :set_lesson

  def show
    @progress.record_view!
    @enrollment.touch_activity!
    @enrollment.log!("lesson.viewed", subject: @lesson) if @progress.saved_change_to_first_viewed_at?
  end

  def complete
    unless @progress.completed?
      @progress.update!(completed_at: Time.current)
      @enrollment.touch_activity!
      @enrollment.log!("lesson.completed", subject: @lesson, metadata: { active_seconds: @progress.active_seconds })
    end
    target = @lesson.checkpoint ? enrollment_assessment_path(@enrollment, @lesson.checkpoint) :
             (@lesson.next_lesson ? enrollment_lesson_path(@enrollment, @lesson.next_lesson) : enrollment_path(@enrollment))
    redirect_to target, notice: "Module « #{@lesson.title} » terminé."
  end

  # Signal de présence envoyé par le navigateur quand la page est visible (temps actif, ind. 19)
  def heartbeat
    @progress.add_active_time!(params[:seconds])
    @enrollment.touch_activity!
    head :no_content
  end

  private

  def set_lesson
    @lesson = @course.lessons.find(params[:id])
    @progress = @enrollment.lesson_progresses.find_or_create_by!(lesson: @lesson)
  end
end

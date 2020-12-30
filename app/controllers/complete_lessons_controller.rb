class CompleteLessonsController < ApplicationController
  before_action :completes

  def index
    @lessons = current_user.complete_lessons
  end

  def create
    @lesson = Lesson.find(params[:lesson_id] || params[:id])
    @workshop = @lesson.workshop_id
    @complete = Complete.create(completed: @lesson, user: current_user)
    redirect_to workshop_lesson_path(@workshop, @lesson), notice: "Changement de statut : Chapitre terminé. Vous pouvez passer au chapitre suivant."
  end

  def destroy
    @lesson = Lesson.find(params[:lesson_id] || params[:id])
    @workshop = @lesson.workshop_id
    Complete.where(completed_id: @lesson, user_id: current_user.id).first.destroy
    redirect_to workshop_lesson_path(@workshop, @lesson), notice: "Changement de statut : Chapitre en cours d'acquisition."
  end

  private

  def completes
    @complete_lessons = current_user.complete_lessons
  end

end

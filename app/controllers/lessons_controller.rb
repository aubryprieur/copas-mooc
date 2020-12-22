class LessonsController < ApplicationController
 before_action :authenticate_admin!, only: [:sort]
 before_action :authenticate_user!, only: [:show]

 def show
  @workshop = Workshop.find(params[:workshop_id])
  @lesson = Lesson.find(params[:id])
  if current_user.already_enrolled?(@workshop)
   @comment = Comment.create
  else
   redirect_to @workshop, alert: "Access denied."
  end
 end

 def sort
  params[:lesson].each_with_index do |id, index|
   Lesson.where(id: id).update_all(order: index + 1)
  end
  head :ok
 end

 private

 def set_lesson
  @lesson = current_lesson
 end

 def lesson_params
  params.require(:lesson).permit(:title, :description, :user_id, :workshop_id, :slug, :order, :video, :remove_video)
 end

end

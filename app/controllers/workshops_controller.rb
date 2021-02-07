class WorkshopsController < ApplicationController
  before_action :set_workshop, only: [:show]

  def index
    @workshops = Workshop.all
  end

  def show
    @instructor = User.find(@workshop.user_id)
    @enrollment = Enrollment.new
    @questions = Question.where(workshop_id: @workshop.id)
    @question = @questions[0]
    @answers = Answer.where(workshop_id: @workshop.id, user_id: current_user)
    @lessons = Lesson.where(workshop_id: @workshop.id)
  end

  private
    def set_workshop
     @workshop = Workshop.find(params[:id])
    end
end

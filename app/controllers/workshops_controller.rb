class WorkshopsController < ApplicationController
  before_action :set_workshop, only: [:show]

  def index
    @workshops = Workshop.all
  end

  def show
    @instructor = User.find(@workshop.user_id)
    @enrollment = Enrollment.new
    @questions = Question.all
    @question = @questions.where(workshop_id: @workshop.id)[0]
  end

  private
    def set_workshop
     @workshop = Workshop.find(params[:id])
    end
end

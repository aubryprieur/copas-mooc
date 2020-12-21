class WorkshopsController < ApplicationController
  before_action :set_workshop, only: [:show]

  def index
    @workshops = Workshop.all
  end

  def show
    @instructor = User.find(@workshop.user_id)
  end

  private
    def set_workshop
     @workshop = Workshop.find(params[:id])
    end
end

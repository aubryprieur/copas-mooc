class EnrollmentsController < ApplicationController
  before_action :authenticate_user!

  def create
    @workshop = Workshop.find(params[:workshop_id])
    if current_user.already_enrolled?(@workshop)
      redirect_to @workshop
      flash[:alert] = "Vous êtes déjà inscrit à la formation."
    else
      @enrollment = current_user.enrollments.create(user_id: params[:enrollment][:user_id], workshop_id: params[:enrollment][:workshop_id])
      redirect_to @workshop
      flash[:success] = "Vous êtes maintenant inscrit à la formation."
    end
  end

end

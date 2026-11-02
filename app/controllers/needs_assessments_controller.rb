# Recueil des besoins d'un participant inscrit par sa structure (sessions intra, ind. 4).
class NeedsAssessmentsController < ApplicationController
  include LearnerEnrollment
  before_action :set_enrollment

  def new
    authorize @enrollment, :owner?
    return redirect_to enrollment_path(@enrollment) if @enrollment.needs_assessment

    @needs = @enrollment.build_needs_assessment(job_title: current_user.job_title)
  end

  def create
    authorize @enrollment, :owner?
    return redirect_to enrollment_path(@enrollment) if @enrollment.needs_assessment

    @needs = @enrollment.build_needs_assessment(needs_params)
    if @needs.save
      @enrollment.log!("needs.submitted")
      redirect_to welcome_enrollment_path(@enrollment), notice: "Merci. Étape suivante : le livret d'accueil."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def needs_params
    params.require(:needs_assessment).permit(:job_title, :work_situations, :expectations, :prior_experience, :questions, :accommodation_contact_requested)
  end
end

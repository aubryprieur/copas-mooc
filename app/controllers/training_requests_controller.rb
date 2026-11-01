# Demande d'une formation sur site par une structure (intra), avec analyse du besoin du commanditaire (ind. 4).
class TrainingRequestsController < ApplicationController
  rate_limit to: 5, within: 1.hour, only: :create,
             with: -> { redirect_to root_path, alert: "Trop d'envois. Réessayez plus tard ou écrivez-nous par courriel." }

  before_action :set_course

  def new
    @request = @course.training_requests.new(contact_name: current_user&.full_name, contact_email: current_user&.email,
                                             organization_name: current_user&.organization_name, contact_role: current_user&.job_title)
  end

  def create
    @request = @course.training_requests.new(request_params)
    if @request.save
      redirect_to course_path(@course), notice: "Demande envoyée. Nous revenons vers vous sous 5 jours ouvrés avec une proposition."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_course
    @course = Course.published.onsite.find_by!(slug: params[:course_id])
  end

  def request_params
    params.require(:training_request).permit(:organization_name, :organization_kind, :contact_name, :contact_email, :contact_phone,
                                             :contact_role, :participants_count, :desired_period, :participants_profile,
                                             :structure_objectives, :constraints, :accessibility_needs)
  end
end

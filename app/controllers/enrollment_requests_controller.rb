# Demande d'inscription sur devis / convention, avec recueil nominatif et bloquant des besoins (ind. 4).
class EnrollmentRequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_course
  before_action :redirect_if_already_enrolled

  def new
    @enrollment = @course.enrollments.new(user: current_user)
    @enrollment.build_needs_assessment(job_title: current_user.job_title)
    @enrollment.employer_name = current_user.organization_name
  end

  def create
    @enrollment = @course.enrollments.new(enrollment_params.merge(user: current_user))
    if @enrollment.save
      @enrollment.log!("enrollment.requested")
      EnrollmentMailer.with(enrollment: @enrollment).requested.deliver_later
      EnrollmentMailer.with(enrollment: @enrollment).notify_team.deliver_later
      redirect_to dashboard_path, notice: "Demande envoyée. Nous l'étudions et revenons vers vous sous 5 jours ouvrés."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_course
    @course = Course.published.find_by!(slug: params[:course_id])
  end

  def redirect_if_already_enrolled
    existing = current_user.enrollment_for(@course)
    redirect_to dashboard_path, notice: "Vous avez déjà une demande pour cette formation." if existing
  end

  def enrollment_params
    params.require(:enrollment).permit(
      :funding_type, :employer_name, :employer_contact, :employer_objectives,
      needs_assessment_attributes: %i[job_title work_situations expectations prior_experience questions accommodation_contact_requested]
    )
  end
end

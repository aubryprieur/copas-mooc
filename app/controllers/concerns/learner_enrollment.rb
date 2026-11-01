module LearnerEnrollment
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
    layout "learning"
  end

  private

  def set_enrollment
    @enrollment = current_user.enrollments.includes(:course).find(params[:enrollment_id] || params[:id])
    @course = @enrollment.course
  end

  def require_learning_access
    authorize @enrollment, :learn?
  end
end

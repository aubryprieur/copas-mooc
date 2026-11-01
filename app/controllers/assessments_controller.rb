class AssessmentsController < ApplicationController
  include LearnerEnrollment
  before_action :set_enrollment
  before_action :set_assessment, :check_access

  def show
    @last_attempt = @enrollment.latest_attempt(@assessment)
    @questions = @assessment.questions.includes(:choices)
  end

  private

  def set_assessment
    @assessment = @course.assessments.find(params[:assessment_id] || params[:id])
  end

  def check_access
    allowed =
      case @assessment.kind
      when "positioning" then @enrollment.user == current_user && (@enrollment.onboarding? || @enrollment.active?)
      when "checkpoint" then policy(@enrollment).learn?
      when "final" then policy(@enrollment).learn? && (@enrollment.final_unlocked? || @enrollment.completed?)
      end
    redirect_to enrollment_path(@enrollment), alert: "Cette évaluation n'est pas encore accessible." unless allowed
  end
end

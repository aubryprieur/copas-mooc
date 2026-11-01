class Admin::SurveysController < Admin::BaseController
  def index
    authorize SurveyResponse
    scope = policy_scope(SurveyResponse).includes(enrollment: %i[course user])
    scope = scope.joins(enrollment: :course).where(courses: { slug: params[:formation] }) if params[:formation].present?
    scope = scope.where(kind: params[:type]) if params[:type].present?
    @averages = SurveyResponse::RATING_FIELDS.keys.index_with { |f| scope.average(f)&.round(1) }
    @pagy, @responses = pagy(scope.order(created_at: :desc))
    @courses = Course.order(:title)
  end
end

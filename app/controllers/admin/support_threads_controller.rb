class Admin::SupportThreadsController < Admin::BaseController
  def index
    authorize SupportThread
    scope = policy_scope(SupportThread).includes(:user, enrollment: :course)
    scope = scope.where(status: params[:statut]) if params[:statut].present?
    @pagy, @threads = pagy(scope.order(Arel.sql("CASE WHEN support_threads.status = 0 THEN 0 ELSE 1 END"), updated_at: :desc))
    answered = SupportThread.where.not(first_response_at: nil).where(created_at: 6.months.ago..)
    @median_response_hours = median(answered.map { (_1.response_time / 3600.0) })
  end

  def show
    @thread = SupportThread.find(params[:id])
    authorize @thread
    @message = @thread.messages.new
  end

  private

  def median(values)
    return if values.empty?

    sorted = values.sort
    mid = sorted.size / 2
    (sorted.size.odd? ? sorted[mid] : (sorted[mid - 1] + sorted[mid]) / 2.0).round(1)
  end
end

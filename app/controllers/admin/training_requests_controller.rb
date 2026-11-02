class Admin::TrainingRequestsController < Admin::BaseController
  def index
    authorize TrainingRequest
    @pagy, @requests = pagy(policy_scope(TrainingRequest).includes(:course, :course_session).order(created_at: :desc))
  end

  def show
    @request = TrainingRequest.find(params[:id])
    authorize @request
  end

  def update
    @request = TrainingRequest.find(params[:id])
    authorize @request
    @request.update!(params.require(:training_request).permit(:status, :internal_note))
    redirect_to admin_training_request_path(@request), notice: "Demande mise à jour."
  end
end

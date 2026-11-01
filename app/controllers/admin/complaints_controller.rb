class Admin::ComplaintsController < Admin::BaseController
  before_action :set_complaint, except: :index

  # Registre des réclamations et aléas (ind. 31) ; signalements visibles du seul référent (ind. 12)
  def index
    authorize Complaint
    scope = policy_scope(Complaint).includes(:course)
    scope = scope.where(category: params[:categorie]) if params[:categorie].present?
    @pagy, @complaints = pagy(scope.order(created_at: :desc))
  end

  def show = authorize(@complaint)

  def update
    authorize @complaint
    if params[:complaint][:response].present?
      @complaint.respond!(by: current_user, response: params[:complaint][:response],
                          improvement_action: params[:complaint][:improvement_action],
                          close: params[:complaint][:close] == "1")
      redirect_to admin_complaint_path(@complaint), notice: "Réponse envoyée et enregistrée au registre."
    else
      @complaint.update!(params.require(:complaint).permit(:status, :internal_note, :improvement_action).merge(handled_by: current_user))
      redirect_to admin_complaint_path(@complaint), notice: "Suivi mis à jour."
    end
  end

  private

  def set_complaint = @complaint = Complaint.find(params[:id])
end

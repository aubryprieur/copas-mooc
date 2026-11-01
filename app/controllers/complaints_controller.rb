class ComplaintsController < ApplicationController
  rate_limit to: 5, within: 1.hour, only: :create,
             with: -> { redirect_to new_complaint_path, alert: "Trop d'envois. Réessayez plus tard ou écrivez-nous par courriel." }

  def new
    @complaint = Complaint.new(category: params[:categorie].presence_in(Complaint.categories.keys) || :complaint,
                               course_id: params[:course_id], name: current_user&.full_name, email: current_user&.email)
  end

  def create
    @complaint = Complaint.new(complaint_params.merge(user: current_user))
    if @complaint.save
      redirect_to root_path, notice: "Votre demande n° #{@complaint.reference} a bien été reçue. Un accusé de réception vous a été envoyé par courriel."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def complaint_params
    params.require(:complaint).permit(:category, :course_id, :name, :email, :description)
  end
end

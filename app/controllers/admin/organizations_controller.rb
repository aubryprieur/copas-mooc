class Admin::OrganizationsController < Admin::BaseController
  before_action :set_organization, only: %i[edit update destroy]

  def index
    authorize Organization
    @organizations = policy_scope(Organization).ordered.includes(:course_sessions)
  end

  def new
    @organization = Organization.new
    authorize @organization
  end

  def create
    @organization = Organization.new(organization_params)
    authorize @organization
    if @organization.save
      redirect_to params[:return_to].presence_in([ new_admin_course_session_path ]) || admin_organizations_path, notice: "Structure enregistrée."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit = authorize(@organization)

  def update
    authorize @organization
    if @organization.update(organization_params)
      redirect_to admin_organizations_path, notice: "Structure enregistrée."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @organization
    if @organization.destroy
      redirect_to admin_organizations_path, notice: "Structure supprimée."
    else
      redirect_to admin_organizations_path, alert: "Cette structure a des sessions : elle est conservée."
    end
  end

  private

  def set_organization = @organization = Organization.find(params[:id])
  def organization_params = params.require(:organization).permit(:name, :kind, :contact_name, :contact_email, :contact_phone, :address)
end

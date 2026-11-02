class Admin::LocationsController < Admin::BaseController
  before_action :set_location, only: %i[edit update destroy]

  def index
    authorize Location
    @locations = policy_scope(Location).ordered
  end

  def new
    @location = Location.new
    authorize @location
  end

  def create
    @location = Location.new(location_params)
    authorize @location
    if @location.save
      redirect_to admin_locations_path, notice: "Lieu enregistré."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit = authorize(@location)

  def update
    authorize @location
    if @location.update(location_params)
      redirect_to admin_locations_path, notice: "Lieu enregistré."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @location
    if @location.destroy
      redirect_to admin_locations_path, notice: "Lieu supprimé."
    else
      redirect_to admin_locations_path, alert: "Ce lieu est utilisé par des sessions : il est conservé."
    end
  end

  private

  def set_location = @location = Location.find(params[:id])
  def location_params = params.require(:location).permit(:name, :address, :access_details, :accessibility, :equipment, :capacity)
end

class Admin::WorkshopsController < ApplicationController
  before_action :authenticate_admin!

  layout "admin"

  def show
    @workshop = Workshop.find(params[:id])
  end

  def index
    @workshops = Workshop.all
  end

  def new
    @workshop = Workshop.new
  end

  def edit
    @workshop = Workshop.find(params[:id])
  end

  def update
    @workshop = Workshop.find(params[:id])
    if @workshop.update_attributes(admin_workshop_params)
      flash[:notice] = "Changements mis à jour avec succès!"
      redirect_back(fallback_location: root_path)
    else
      flash[:notice] = "Impossible de mettre à jour, veuillez réessayer"
      render :edit, alert: "Impossible de mettre à jour, veuillez réessayer"
    end
  end

  def create
    @workshop = Workshop.new(admin_workshop_params)

    respond_to do |format|
      if @workshop.save
        format.html { redirect_to admin_workshops_url, notice: "L'atelier a été créé avec succès." }
        format.json { render json: @workshop, status: :created, location: [:admin,@workshop] }
      else
        format.html { render action: "new" }
        format.json { render json: @workshop.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @workshop.destroy
    redirect_to root_url, notice: "Suppression de la session réussie"
  end

  private

  def set_workshop
    @workshop = current_workshop
  end

  def admin_workshop_params
    params.require(:workshop).permit(:title, :subtitle, :user_id, :difficulty, :category, :language, :requirements, :outcomes, :cost, :discount, :photo, :remove_image, :rich_body)
  end

end

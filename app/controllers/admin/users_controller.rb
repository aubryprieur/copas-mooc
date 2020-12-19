class Admin::UsersController < ApplicationController
  before_action :authenticate_admin!

  layout "admin"

  def show
    @user = User.find(params[:id])
  end

  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(admin_user_params)
      flash[:notice] = "Changements mis à jour avec succès !"
      redirect_back(fallback_location: root_path)
    else
      flash[:notice] = "Impossible de mettre à jour, veuillez réessayer"
      render :edit, alert: "Impossible de mettre à jour, veuillez réessayer"
    end
  end

  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        format.html { redirect_to admin_users_url, notice: "L'utilisateur a été créé avec succès." }
        format.json { render json: @user, status: :created, location: [:admin,@user] }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @user.destroy
    redirect_to root_url, notice: "L'utilisateur a été supprimé avec succès"
  end

  private

  def set_user
    @user = current_user
  end

  def admin_user_params
    params.require(:user).permit(:first_name, :last_name, :email, :unconfirmed_email, :image, :remove_image)
  end

end

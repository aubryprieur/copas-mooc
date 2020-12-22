class UsersController < ApplicationController
  before_action :set_user_per_params, only: [:show]
  before_action :set_current_user, only: [:profile, :avatar, :update]

  def show
  end

  def profile
  end

  def avatar
  end

  def update
    if @user.update(user_params)
      flash[:notice] = "Vos modifications ont été enregistrées."
      redirect_back(fallback_location: root_path)
    else
      flash[:notice] = "Impossible de mettre à jour, veuillez réessayer"
    end
  end


  private

  def set_user_per_params
    @user = User.find(params[:id])
  end

  def set_current_user
    @user = current_user
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :photo, :description)
  end
end

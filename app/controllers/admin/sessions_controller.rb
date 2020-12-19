class Admin::SessionsController < Devise::SessionsController
 before_action :check_if_user_signed_in, only: [:new]

 def new
  self.resource = resource_class.new(sign_in_params)
  store_location_for(resource, params[:redirect_to])
 end

 def create
  self.resource = warden.authenticate!(auth_options)
  set_flash_message!(:notice, :signed_in)
  sign_in(resource_name, resource)
  yield resource if block_given?
  respond_with resource, location: after_sign_in_path_for(resource)
 end

 def destroy
  super
 end

 protected

  def check_if_user_signed_in
   if user_signed_in?
    redirect_to root_path, alert: "Veuillez d'abord signer."
   end
  end

end

class Admin::StaticPagesController < ApplicationController
  before_action :authenticate_admin!

  layout "admin"

  def dashboard
  end

end

class PagesController < ApplicationController
  def show
    @page = Page.fetch(params[:slug]) or raise ActiveRecord::RecordNotFound
  end
end

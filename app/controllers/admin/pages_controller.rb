class Admin::PagesController < Admin::BaseController
  def index
    authorize Page
    @pages = Page.order(:title)
  end

  def edit
    @page = Page.find_by!(slug: params[:id])
    authorize @page
  end

  def update
    @page = Page.find_by!(slug: params[:id])
    authorize @page
    if @page.update(params.require(:page).permit(:title, :body, :published))
      redirect_to admin_pages_path, notice: "Page « #{@page.title} » enregistrée."
    else
      render :edit, status: :unprocessable_entity
    end
  end
end

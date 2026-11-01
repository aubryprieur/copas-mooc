class CoursesController < ApplicationController
  def index
    @courses = Course.catalog.with_attached_cover.includes(:lessons)
    @categories = @courses.map(&:category).compact.uniq.sort
    @courses = @courses.where(category: params[:categorie]) if params[:categorie].present?
  end

  def show
    @course = Course.published.find_by!(slug: params[:id])
    @enrollment = current_user&.enrollment_for(@course)
    @indicators = @course.results_indicators
  end
end

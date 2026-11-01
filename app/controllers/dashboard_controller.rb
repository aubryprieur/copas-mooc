class DashboardController < ApplicationController
  before_action :authenticate_user!

  def show
    @enrollments = current_user.enrollments.includes(course: [ :lessons, { cover_attachment: :blob } ]).order(updated_at: :desc)
    @threads = current_user.support_threads.order(updated_at: :desc).limit(5)
  end
end

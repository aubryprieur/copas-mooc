class SupportThreadsController < ApplicationController
  before_action :authenticate_user!

  def index
    @threads = current_user.support_threads.includes(:enrollment).order(updated_at: :desc)
  end

  def show
    @thread = current_user.support_threads.find(params[:id])
    @message = @thread.messages.new
  end

  def new
    @thread = current_user.support_threads.new(category: params[:category].presence_in(%w[pedagogical technical]) || "pedagogical",
                                               enrollment_id: params[:enrollment_id], lesson_id: params[:lesson_id])
    @thread.messages.build
  end

  def create
    @thread = current_user.support_threads.new(thread_params)
    @thread.enrollment = nil unless @thread.enrollment&.user_id == current_user.id
    body = params.dig(:support_thread, :body).to_s
    message = @thread.messages.build(author: current_user, body: body)
    if body.present? && @thread.save
      redirect_to support_thread_path(@thread), notice: "Message envoyé. L'équipe vous répond sous 2 jours ouvrés."
    else
      @thread.errors.add(:base, "Écrivez votre message") if message.body.blank?
      render :new, status: :unprocessable_entity
    end
  end

  def close
    thread = current_user.support_threads.find(params[:id])
    thread.update!(status: :closed, closed_at: Time.current)
    redirect_to support_threads_path, notice: "Échange clos."
  end

  private

  def thread_params
    params.require(:support_thread).permit(:category, :subject, :enrollment_id, :lesson_id)
  end
end

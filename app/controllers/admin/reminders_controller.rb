class Admin::RemindersController < Admin::BaseController
  def create
    enrollment = Enrollment.find(params[:enrollment_id])
    authorize enrollment, :remind?
    reminder = enrollment.reminders.new(kind: :manual, sent_by: current_user, message: params.dig(:reminder, :message), sent_at: Time.current)
    if reminder.save
      ReminderMailer.with(reminder: reminder).manual.deliver_later
      redirect_to admin_enrollment_path(enrollment, anchor: "relances"), notice: "Relance envoyée et tracée."
    else
      redirect_to admin_enrollment_path(enrollment, anchor: "relances"), alert: "Écrivez un message de relance."
    end
  end
end

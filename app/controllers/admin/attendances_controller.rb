# Correction d'une présence après clôture : motif obligatoire, tracé dans le journal.
class Admin::AttendancesController < Admin::BaseController
  def update
    attendance = Attendance.find(params[:id])
    authorize attendance
    attendance.assign_attributes(params.require(:attendance).permit(:status, :arrived_at, :left_at))
    attendance.correction_reason = params.dig(:attendance, :correction_reason)
    attendance.corrected_by = current_user
    attendance.recorded_by = current_user
    slot = attendance.session_slot
    if attendance.save
      redirect_to admin_course_session_path(slot.course_session, anchor: "presences"), notice: "Présence corrigée, motif enregistré."
    else
      redirect_to admin_course_session_path(slot.course_session, anchor: "presences"), alert: attendance.errors.full_messages.to_sentence
    end
  end
end

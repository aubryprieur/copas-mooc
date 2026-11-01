# Écran « Aujourd'hui » du formateur : ses demi-journées du jour et des 7 prochains jours.
class Admin::TodayController < Admin::BaseController
  def show
    authorize :backoffice, :index?
    sessions = policy_scope(CourseSession).where.not(status: :cancelled)
    @today = SessionSlot.where(course_session: sessions, date: Date.current).includes(course_session: %i[course organization location]).order(:starts_at)
    @upcoming = SessionSlot.where(course_session: sessions, date: (Date.current + 1)..(Date.current + 14))
                           .includes(course_session: %i[course organization]).order(:date, :starts_at)
    @to_close = SessionSlot.where(course_session: sessions, status: %i[planned open]).where(date: ...Date.current)
                           .includes(course_session: %i[course organization]).order(:date)
  end
end

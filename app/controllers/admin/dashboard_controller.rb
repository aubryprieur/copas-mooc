class Admin::DashboardController < Admin::BaseController
  def show
    authorize :backoffice, :index?
    @pending_requests = Enrollment.requested.includes(:user, :course).order(:requested_at)
    @onboarding = Enrollment.onboarding.count
    @active = Enrollment.active.count
    # Alertes de décrochage (ind. 19) : apprenants actifs inactifs au-delà du seuil d'alerte de leur formation
    @dropouts = Enrollment.active.includes(:user, :course).select { |e| e.days_inactive.to_i >= e.course.inactivity_alert_days }
    @open_threads = SupportThread.awaiting_staff.includes(:user).order(:updated_at)
    @open_complaints = policy_scope(Complaint).open_items.order(:created_at)
    @recent_events = ActivityEvent.recent_first.includes(:user, enrollment: :course).limit(12)
    @training_requests = TrainingRequest.received.includes(:course).order(:created_at)
    @slots_to_close = SessionSlot.where(course_session: policy_scope(CourseSession), status: %i[planned open]).where(date: ...Date.current)
                                 .includes(course_session: %i[course organization]).order(:date)
    @satisfaction = SurveyResponse.hot.where(created_at: 12.months.ago..).average(:overall_rating)&.round(1)
  end
end

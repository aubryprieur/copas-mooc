require "test_helper"

class InactivityReminderJobTest < ActiveJob::TestCase
  test "relance après inactivité puis alerte de décrochage, sans doublon (ind. 19)" do
    course = create_course(inactivity_reminder_days: 7, inactivity_alert_days: 14)
    e = request_enrollment(create_user, course)
    e.update!(status: :active, started_at: 8.days.ago, last_activity_at: 8.days.ago)

    InactivityReminderJob.perform_now
    InactivityReminderJob.perform_now
    assert_equal 1, e.reminders.automatic.count

    e.update!(last_activity_at: 15.days.ago, started_at: 15.days.ago)
    e.reminders.update_all(sent_at: 16.days.ago)
    InactivityReminderJob.perform_now
    assert_equal 1, e.reminders.alert.count
    assert e.activity_events.exists?(action: "reminder.sent")
  end
end

class SupportMessage < ApplicationRecord
  belongs_to :support_thread, touch: true
  belongs_to :author, class_name: "User"

  validates :body, presence: true, length: { maximum: 5000 }

  after_create_commit :update_thread_and_notify

  private

  def update_thread_and_notify
    thread = support_thread
    if author.staff?
      thread.update!(status: :answered, first_response_at: thread.first_response_at || created_at)
      SupportMailer.with(message: self).reply_to_learner.deliver_later
    else
      thread.update!(status: :open)
      SupportMailer.with(message: self).new_question.deliver_later
    end
    thread.enrollment&.log!("support.message", user: author, subject: self,
                            metadata: { thread_id: thread.id, category: thread.category })
  end
end

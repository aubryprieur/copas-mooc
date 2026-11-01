class Reminder < ApplicationRecord
  # automatic : relance apprenant après inactivité ; alert : alerte de décrochage au référent ; manual : relance tuteur
  enum :kind, { automatic: 0, alert: 1, manual: 2 }
  KIND_LABELS = { "automatic" => "Relance automatique", "alert" => "Alerte de décrochage", "manual" => "Relance du formateur" }.freeze

  belongs_to :enrollment
  belongs_to :sent_by, class_name: "User", optional: true

  validates :sent_at, presence: true
  validates :message, presence: true, if: :manual?

  after_create_commit do
    enrollment.log!("reminder.sent", user: sent_by, subject: self, metadata: { kind: kind })
  end

  def kind_label = KIND_LABELS.fetch(kind)
end

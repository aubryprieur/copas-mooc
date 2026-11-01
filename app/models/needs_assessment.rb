class NeedsAssessment < ApplicationRecord
  belongs_to :enrollment
  validates :job_title, :work_situations, :expectations, presence: true
  validates :work_situations, :expectations, length: { minimum: 20, message: "doit être un peu plus détaillé (20 caractères minimum)" }
end

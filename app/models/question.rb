class Question < ApplicationRecord
  validates :question, presence: true, length: { within: 5..100 }
  validates :answer, presence: true
  validates :distractor_1, presence: true
  belongs_to :workshop
end

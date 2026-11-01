class Choice < ApplicationRecord
  belongs_to :question, inverse_of: :choices
  validates :label, presence: true
end

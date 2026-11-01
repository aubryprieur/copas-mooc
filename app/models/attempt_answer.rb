class AttemptAnswer < ApplicationRecord
  belongs_to :attempt
  belongs_to :question
  belongs_to :choice, optional: true
end

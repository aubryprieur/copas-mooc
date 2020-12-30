class Complete < ApplicationRecord
  belongs_to :user
  belongs_to :completed, polymorphic: true
end

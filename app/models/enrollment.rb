class Enrollment < ActiveRecord::Base
  belongs_to :workshop
  belongs_to :user, inverse_of: :enrollments
end

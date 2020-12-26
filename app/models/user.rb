class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  has_many :comments, as: :commentable
  has_one_attached :photo
  has_many :enrollments, dependent: :destroy
  has_many :enrolled_workshops, through: :enrollments, source: :workshop
  has_many :charges

  def already_enrolled?(workshop)
    return enrolled_workshops.include?(workshop)
  end

  def full_name
   "#{first_name} #{last_name}"
  end

  protected
  def confirmation_required?
    false
  end

end

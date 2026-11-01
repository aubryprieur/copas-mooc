class Objective < ApplicationRecord
  belongs_to :course, inverse_of: :objectives
  has_many :lesson_objectives, dependent: :destroy
  has_many :lessons, through: :lesson_objectives
  has_many :questions, dependent: :nullify

  validates :description, presence: true

  def label = "#{position}. #{description}"
end

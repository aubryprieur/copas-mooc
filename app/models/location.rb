# Lieu de formation (indicateur 17 : moyens et locaux, accessibilité).
class Location < ApplicationRecord
  has_many :course_sessions, dependent: :restrict_with_error

  validates :name, :address, presence: true
  validates :capacity, numericality: { greater_than: 0 }, allow_nil: true

  scope :ordered, -> { order(:name) }
end

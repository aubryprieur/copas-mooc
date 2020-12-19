class Workshop < ApplicationRecord
  validates :title, presence: true, length: { within: 1..100 }
  validates :discount, numericality: { less_than_or_equal_to: 100 }

  belongs_to :user
  has_one_attached :photo

  scope :published, -> { where(status: 'published') }
  scope :drafts, -> { where(status: 'draft') }
end

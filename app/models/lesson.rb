class Lesson < ApplicationRecord
  belongs_to :course, inverse_of: :lessons
  has_many :lesson_objectives, dependent: :destroy
  has_many :objectives, through: :lesson_objectives
  has_many :lesson_progresses, dependent: :destroy
  has_one :checkpoint, -> { where(kind: :checkpoint) }, class_name: "Assessment", dependent: :nullify

  has_rich_text :content
  has_one_attached :video
  # Sous-titres WebVTT pour l'accessibilité (RGAA / WCAG 2.1 AA)
  has_one_attached :captions
  has_many_attached :resources

  validates :title, presence: true, length: { maximum: 120 }
  validates :estimated_minutes, numericality: { greater_than: 0 }
  validate :captions_must_be_webvtt

  before_create { self.position = (course.lessons.maximum(:position) || 0) + 1 if position.to_i.zero? }

  def next_lesson = course.lessons.where("position > ?", position).first
  def previous_lesson = course.lessons.where("position < ?", position).last
  def number = course.lessons.index(self).to_i + 1

  private

  def captions_must_be_webvtt
    return unless captions.attached?
    return if captions.filename.extension.casecmp?("vtt")

    errors.add :captions, "doivent être un fichier WebVTT (.vtt)"
  end
end

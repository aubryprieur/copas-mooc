class Question < ApplicationRecord
  belongs_to :assessment
  belongs_to :objective, optional: true
  has_many :choices, -> { order(:position) }, dependent: :destroy, inverse_of: :question
  has_many :attempt_answers, dependent: :restrict_with_error

  accepts_nested_attributes_for :choices, allow_destroy: true, reject_if: ->(a) { a["label"].blank? }

  validates :prompt, presence: true
  validate :exactly_one_correct_choice

  before_create { self.position = (assessment.questions.maximum(:position) || 0) + 1 if position.to_i.zero? }

  def correct_choice = choices.detect(&:correct?)

  private

  def exactly_one_correct_choice
    kept = choices.reject(&:marked_for_destruction?)
    errors.add :base, "Indiquez au moins deux réponses possibles" if kept.size < 2
    errors.add :base, "Cochez une et une seule bonne réponse" unless kept.count(&:correct?) == 1
  end
end

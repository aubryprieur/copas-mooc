class Attempt < ApplicationRecord
  belongs_to :assessment
  belongs_to :enrollment
  has_many :attempt_answers, dependent: :destroy

  scope :submitted, -> { where.not(submitted_at: nil) }

  def submitted? = submitted_at.present?

  # Enregistre les réponses, calcule le score global et le score par objectif (ind. 11).
  def grade!(answers_by_question)
    transaction do
      assessment.questions.includes(:choices).each do |question|
        choice = question.choices.find_by(id: answers_by_question[question.id.to_s])
        attempt_answers.create!(question: question, choice: choice, correct: choice&.correct? || false)
      end
      answers = attempt_answers.includes(:question).to_a
      total = answers.size
      good = answers.count(&:correct?)
      self.score = total.zero? ? 0 : (good * 100.0 / total).round
      self.passed = score >= assessment.threshold
      self.objective_scores = answers.select { _1.question.objective_id }
                                     .group_by { _1.question.objective_id }
                                     .transform_values { |list| (list.count(&:correct?) * 100.0 / list.size).round }
      self.submitted_at = Time.current
      save!
    end
    enrollment.log!("assessment.submitted", subject: self,
                    metadata: { kind: assessment.kind, score: score, passed: passed })
    self
  end

  def objective_acquired?(objective)
    value = objective_scores[objective.id.to_s]
    value && value >= assessment.threshold
  end
end

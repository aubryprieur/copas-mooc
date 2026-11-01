class Assessment < ApplicationRecord
  # positioning : ind. 8 (entrée) ; checkpoint : jalons (D6313-3-1) ; final : ind. 11 et L6353-1
  enum :kind, { positioning: 0, checkpoint: 1, final: 2 }

  KIND_LABELS = {
    "positioning" => "Positionnement d'entrée",
    "checkpoint" => "Quiz de module",
    "final" => "Évaluation finale"
  }.freeze

  belongs_to :course
  belongs_to :lesson, optional: true
  has_many :questions, -> { order(:position) }, dependent: :destroy
  has_many :attempts, dependent: :restrict_with_error

  validates :title, presence: true
  validates :kind, uniqueness: { scope: :course_id }, if: -> { positioning? || final? }
  validates :lesson, presence: true, if: :checkpoint?

  def threshold = positioning? ? course.positioning_threshold : course.pass_threshold
  def kind_label = KIND_LABELS.fetch(kind)
  # Le positionnement et les quiz de module peuvent être refaits ; l'évaluation finale une seule fois.
  def retakable? = checkpoint?
end

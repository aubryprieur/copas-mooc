# Indicateur 2 : résultats chiffrés, avec période, effectif et formule de calcul publiés.
class CourseIndicators
  # En dessous de cet effectif, les taux ne sont pas publiés (un taux sur 1 ou 2 personnes induirait en erreur, ind. 1).
  MIN_BASE = 5

  Indicator = Data.define(:key, :label, :value, :unit, :base, :formula)

  attr_reader :course, :since

  def initialize(course, since:)
    @course = course
    @since = since
  end

  def period_label = "du #{I18n.l(since.to_date)} au #{I18n.l(Date.current)}"

  def started = @started ||= enrollments.where.not(started_at: nil)
  def finished = @finished ||= enrollments.where(status: %i[completed abandoned])

  def all
    [ effectif, realisation, abandon, reussite, satisfaction, recommandation ].compact
  end

  def effectif
    Indicator.new(:effectif, "Apprenants ayant commencé le parcours", started.count, "", nil,
                  "Nombre d'inscrits ayant démarré la formation sur la période.")
  end

  # Guide V10 : en asynchrone, taux de réalisation = activités réalisées / activités prévues.
  def realisation
    base = started.to_a
    return if base.empty?

    value = (base.sum(&:progress_percent) / base.size.to_f).round
    Indicator.new(:realisation, "Taux de réalisation du parcours", value, "%", base.size,
                  "Moyenne, pour chaque apprenant ayant commencé, du nombre de modules terminés divisé par le nombre de modules prévus.")
  end

  def abandon
    base = finished.count
    return if base.zero?

    value = (enrollments.abandoned.count * 100.0 / base).round
    Indicator.new(:abandon, "Taux d'abandon", value, "%", base,
                  "Abandons divisés par le nombre de parcours terminés ou abandonnés sur la période.")
  end

  def reussite
    attempts = Attempt.submitted.joins(:assessment).where(assessments: { course_id: course.id, kind: :final })
                      .where(submitted_at: since..)
    base = attempts.count
    return if base.zero?

    Indicator.new(:reussite, "Taux de réussite à l'évaluation finale", (attempts.where(passed: true).count * 100.0 / base).round, "%", base,
                  "Évaluations finales atteignant le seuil de #{course.pass_threshold} % divisées par le nombre d'évaluations finales rendues.")
  end

  def satisfaction
    responses = hot_responses
    return if responses.empty?

    value = (responses.average(:overall_rating).to_f).round(1)
    rate = finished_base.zero? ? nil : (responses.count * 100.0 / finished_base).round
    Indicator.new(:satisfaction, "Satisfaction globale", value, "/5", responses.count,
                  "Moyenne des notes de satisfaction globale (1 à 5) du questionnaire de fin de formation." +
                  (rate ? " Taux de réponse : #{rate} %." : ""))
  end

  def recommandation
    responses = hot_responses.where.not(recommend_score: nil)
    return if responses.empty?

    value = (responses.where(recommend_score: 7..).count * 100.0 / responses.count).round
    Indicator.new(:recommandation, "Recommanderaient la formation", value, "%", responses.count,
                  "Part des répondants ayant donné une note de 7 ou plus sur 10 à la question « Recommanderiez-vous cette formation ? ».")
  end

  private

  def enrollments = course.enrollments.where(requested_at: since..).or(course.enrollments.where(started_at: since..))
  def hot_responses = SurveyResponse.hot.joins(:enrollment).where(enrollments: { course_id: course.id }).where(created_at: since..)
  def finished_base = enrollments.completed.count
end

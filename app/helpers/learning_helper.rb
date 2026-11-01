module LearningHelper
  # Les étapes réelles du parcours apprenant, dans l'ordre (sert au tracé « parcours »).
  def journey_steps(enrollment)
    course = enrollment.course
    lessons_total = course.lessons.size
    done = enrollment.completed_lesson_ids.size
    [
      { title: "Demande et recueil de vos besoins", done: true },
      { title: "Validation de l'inscription", done: enrollment.approved_at.present?,
        current: enrollment.requested? },
      { title: "Livret d'accueil", done: enrollment.welcome_acknowledged_at.present?,
        current: enrollment.onboarding? && enrollment.welcome_acknowledged_at.nil?,
        path: enrollment.onboarding? ? welcome_enrollment_path(enrollment) : nil },
      { title: "Positionnement d'entrée", done: enrollment.positioning_done?,
        current: enrollment.onboarding? && enrollment.welcome_acknowledged_at.present? && !enrollment.positioning_done?,
        path: (enrollment.onboarding? && course.positioning_assessment) ? enrollment_assessment_path(enrollment, course.positioning_assessment) : nil },
      { title: "Modules (#{done}/#{lessons_total})", done: lessons_total.positive? && done >= lessons_total,
        current: enrollment.active? && done < lessons_total },
      { title: "Évaluation finale", done: enrollment.final_attempt.present?,
        current: enrollment.final_unlocked? && enrollment.final_attempt.nil?,
        path: enrollment.final_unlocked? && course.final_assessment ? enrollment_assessment_path(enrollment, course.final_assessment) : nil },
      { title: "Votre avis sur la formation", done: enrollment.hot_survey.present?,
        current: enrollment.completed? && enrollment.hot_survey.nil?,
        path: enrollment.completed? && enrollment.hot_survey.nil? ? new_enrollment_survey_path(enrollment) : nil },
      { title: "Attestation de fin de formation", done: enrollment.certificate_issued_at.present?,
        path: enrollment.completed? ? certificate_enrollment_path(enrollment) : nil }
    ]
  end

  def next_lesson_for(enrollment)
    enrollment.course.lessons.detect { |l| !enrollment.lesson_completed?(l) } || enrollment.course.lessons.first
  end
end

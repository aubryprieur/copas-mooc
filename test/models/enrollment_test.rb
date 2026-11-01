require "test_helper"

class EnrollmentTest < ActiveSupport::TestCase
  setup do
    @course = create_course
    @admin = create_user(role: :admin)
    @learner = create_user
  end

  test "le recueil des besoins est obligatoire pour s'inscrire (ind. 4)" do
    enrollment = @course.enrollments.new(user: @learner, funding_type: :self_funded)
    assert_not enrollment.valid?
    assert_includes enrollment.errors.attribute_names, :needs_assessment
  end

  test "parcours complet : validation, accueil, positionnement, modules, évaluation finale, attestation" do
    e = request_enrollment(@learner, @course)
    assert e.requested?

    e.approve!(by: @admin, convention_reference: "CONV-1")
    assert e.onboarding?

    e.acknowledge_welcome!
    assert e.onboarding?, "le parcours ne s'ouvre qu'après le positionnement"

    attempt = e.attempts.create!(assessment: @course.positioning_assessment).grade!(answers_for(@course.positioning_assessment))
    e.decide_positioning!(attempt)
    assert e.reload.active?
    assert e.positioning_direct_access?

    assert_not e.final_unlocked?, "l'évaluation finale est fermée tant que les modules ne sont pas terminés"
    @course.lessons.each { |l| e.lesson_progresses.create!(lesson: l, completed_at: Time.current) }
    e.instance_variable_set(:@completed_lesson_ids, nil)
    assert e.final_unlocked?
    assert_equal 100, e.progress_percent

    final = e.attempts.create!(assessment: @course.final_assessment).grade!(answers_for(@course.final_assessment))
    e.complete!(final)
    assert e.reload.completed?
    assert_equal 100, final.score
    assert final.passed
    assert final.objective_acquired?(@course.objectives.first)
    assert_match(/\ACA-\d{4}-\d{5}\z/, e.certificate_number)

    actions = e.activity_events.chronological.pluck(:action)
    %w[enrollment.approved welcome.acknowledged assessment.submitted positioning.decided enrollment.started enrollment.completed].each do |a|
      assert_includes actions, a
    end
  end

  test "un positionnement faible oriente vers le référent avant d'ouvrir le parcours (ind. 8)" do
    e = request_enrollment(@learner, @course)
    e.approve!(by: @admin)
    e.acknowledge_welcome!
    attempt = e.attempts.create!(assessment: @course.positioning_assessment).grade!(answers_for(@course.positioning_assessment, correct: false))
    e.decide_positioning!(attempt)
    assert e.positioning_referent_contact?
    assert e.reload.active?
    assert_match(/seuil 50 %/, e.positioning_note)
  end

  test "le journal d'activité ne peut pas être modifié" do
    e = request_enrollment(@learner, @course)
    event = e.log!("enrollment.requested")
    assert_raises(ActiveRecord::ReadOnlyRecord) { event.update!(action: "autre") }
  end

  test "le PDF d'attestation et le relevé de participation sont générés" do
    e = request_enrollment(@learner, @course)
    e.approve!(by: @admin)
    e.acknowledge_welcome!
    e.decide_positioning!(e.attempts.create!(assessment: @course.positioning_assessment).grade!(answers_for(@course.positioning_assessment)))
    final = e.attempts.create!(assessment: @course.final_assessment).grade!(answers_for(@course.final_assessment))
    e.complete!(final)
    assert CertificatePdf.new(e).render.start_with?("%PDF")
    assert ParticipationReportPdf.new(e).render.start_with?("%PDF")
  end
end

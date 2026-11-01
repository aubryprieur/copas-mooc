require "test_helper"

# Non-régression des failles de l'ancienne version et contrôle des accès.
class SecurityTest < ActionDispatch::IntegrationTest
  setup do
    @course = create_course
    @learner = create_user
    @other = create_user
  end

  test "impossible de s'inscrire sans passer par la demande avec recueil des besoins" do
    sign_in @learner
    assert_no_difference("Enrollment.count") do
      post course_enrollment_request_path(@course), params: { enrollment: { funding_type: "self_funded" } }
    end
    assert_response :unprocessable_entity
  end

  test "une demande d'inscription n'ouvre pas l'accès aux modules" do
    sign_in @learner
    e = request_enrollment(@learner, @course)
    get enrollment_lesson_path(e, @course.lessons.first)
    assert_redirected_to root_path
  end

  test "un apprenant ne peut pas consulter le parcours d'un autre" do
    e = request_enrollment(@other, @course)
    sign_in @learner
    get enrollment_path(e)
    assert_response :not_found
  end

  test "l'espace de gestion est fermé aux apprenants" do
    sign_in @learner
    get admin_root_path
    assert_redirected_to root_path
  end

  test "l'auditeur consulte sans pouvoir modifier (ind. 17)" do
    sign_in create_user(role: :auditor)
    get admin_enrollments_path
    assert_response :success
    get new_admin_course_path
    assert_response :redirect
    patch admin_course_path(@course), params: { course: { title: "Piraté" } }
    assert_not_equal "Piraté", @course.reload.title
  end

  test "un signalement n'est visible que du référent désigné (ind. 12)" do
    report = Complaint.create!(category: :report, name: "X", email: "x@exemple.fr", description: "Situation de harcèlement en classe virtuelle")
    sign_in create_user(role: :admin)
    get admin_complaint_path(report)
    assert_response :redirect
    sign_out :user
    sign_in create_user(role: :admin, reports_referent: true)
    get admin_complaint_path(report)
    assert_response :success
  end

  test "l'évaluation finale ne peut être rendue qu'une fois" do
    admin = create_user(role: :admin)
    e = request_enrollment(@learner, @course)
    e.approve!(by: admin)
    e.acknowledge_welcome!
    e.decide_positioning!(e.attempts.create!(assessment: @course.positioning_assessment).grade!(answers_for(@course.positioning_assessment)))
    @course.lessons.each { |l| e.lesson_progresses.create!(lesson: l, completed_at: Time.current) }
    sign_in @learner
    final = @course.final_assessment
    post enrollment_assessment_attempts_path(e, final), params: { answers: answers_for(final, correct: false) }
    assert_difference("Attempt.count", 0) do
      post enrollment_assessment_attempts_path(e, final), params: { answers: answers_for(final) }
    end
    assert_equal 0, e.reload.final_attempt.score
  end

  test "la réclamation reçoit un numéro et un accusé de réception (ind. 31)" do
    assert_difference("Complaint.count") do
      post complaints_path, params: { complaint: { category: "complaint", name: "Léa", email: "lea@exemple.fr", description: "La vidéo ne se charge pas." } }
    end
    complaint = Complaint.last
    assert complaint.acknowledged_at.present?
    assert_match(/\AR-\d{6}-[A-Z0-9]{5}\z/, complaint.reference)
  end

  test "les mots de passe faibles sont refusés" do
    post user_registration_path, params: { user: { first_name: "A", last_name: "B", email: "faible@exemple.fr",
                                                     password: "azerty", password_confirmation: "azerty", accept_terms: "1" } }
    assert_response :unprocessable_entity
  end
end

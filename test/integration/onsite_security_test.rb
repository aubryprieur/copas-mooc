require "test_helper"

class OnsiteSecurityTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create_user(role: :admin)
    @trainer = create_user(role: :trainer)
    @session = create_onsite_session(mode: :drawn, trainer: @trainer,
                                     slots: [ { date: Date.current, starts_at: "00:00", ends_at: "23:59" } ])
    @slot = @session.slots.first
    @enrollment = ParticipantImport.new(@session, invited_by: @admin).add(first_name: "Anne", last_name: "Martin", email: "anne@ville.fr")
    @learner = @enrollment.user
  end

  test "un apprenant signe sa présence pendant la demi-journée, une seule fois" do
    sign_in @learner
    post sign_slot_path(@slot.sign_token), params: { signature: "data:image/png;base64," + ("A" * 800) }
    assert @slot.attendances.find_by(enrollment: @enrollment).present?
    signed_at = @slot.attendances.find_by(enrollment: @enrollment).signed_at
    post sign_slot_path(@slot.sign_token), params: { signature: "data:image/png;base64," + ("B" * 800) }
    assert_equal signed_at, @slot.attendances.find_by(enrollment: @enrollment).signed_at
  end

  test "une signature vide est refusée" do
    sign_in @learner
    post sign_slot_path(@slot.sign_token), params: { signature: "" }
    assert_nil @slot.attendances.find_by(enrollment: @enrollment)
  end

  test "impossible de signer pour une session à laquelle on n'est pas inscrit" do
    sign_in create_user
    post sign_slot_path(@slot.sign_token), params: { signature: "data:image/png;base64," + ("A" * 800) }
    assert_redirected_to dashboard_path
    assert_equal 0, @slot.attendances.count
  end

  test "la signature est refusée en dehors de la demi-journée" do
    session = create_onsite_session(mode: :click, slots: [ { date: Date.current + 3, starts_at: "09:00", ends_at: "12:00" } ])
    enrollment = ParticipantImport.new(session, invited_by: @admin).add(first_name: "Paul", last_name: "Roux", email: "paul@ville.fr")
    sign_in enrollment.user
    post sign_slot_path(session.slots.first.sign_token)
    assert_equal 0, session.slots.first.attendances.count
  end

  test "tablette : le code personnel est vérifié" do
    sign_in @trainer
    patch open_admin_session_slot_path(@slot)
    post tablet_sign_admin_session_slot_path(@slot), params: { enrollment_id: @enrollment.id, code: "0000" == @enrollment.attendance_code ? "1111" : "0000", signature: "data:image/png;base64," + ("A" * 800) }
    assert_equal 0, @slot.attendances.count
    post tablet_sign_admin_session_slot_path(@slot), params: { enrollment_id: @enrollment.id, code: @enrollment.attendance_code, signature: "data:image/png;base64," + ("A" * 800) }
    assert @slot.attendances.find_by(enrollment: @enrollment).signed_by_tablet?
  end

  test "un formateur ne gère pas l'émargement d'une session qu'il n'anime pas" do
    sign_in create_user(role: :trainer)
    patch mark_admin_session_slot_path(@slot), params: { enrollment_id: @enrollment.id, status: "present" }
    assert_equal 0, @slot.attendances.count
  end

  test "l'avis du commanditaire passe par un lien secret, une seule fois" do
    get new_client_survey_path(token: "mauvais-jeton")
    assert_response :not_found
    post client_survey_path(token: @session.access_token), params: { client_survey: { overall_rating: 4, comment: "Très utile" } }
    assert_equal 4, @session.reload.client_survey.overall_rating
    post client_survey_path(token: @session.access_token), params: { client_survey: { overall_rating: 1 } }
    assert_equal 4, @session.reload.client_survey.overall_rating
  end

  test "un apprenant n'accède pas aux supports d'une session qui n'est pas la sienne" do
    @session.materials.attach(io: StringIO.new("support"), filename: "support.pdf", content_type: "application/pdf")
    sign_in create_user
    get enrollment_material_path(@enrollment, @session.materials.first.id)
    assert_response :not_found
  end

  test "demande de formation d'une structure depuis la fiche publique" do
    @session.course.update!(status: :published)
    assert_difference("TrainingRequest.count") do
      post course_training_request_path(@session.course), params: { training_request: {
        organization_name: "Mairie de Lens", organization_kind: "collectivite", contact_name: "Léa Petit", contact_email: "lea@lens.fr",
        participants_count: 10, participants_profile: "Agents du service vie associative", structure_objectives: "Lancer un budget participatif en 2027 avec les services"
      } }
    end
    assert_redirected_to course_path(@session.course)
  end
end

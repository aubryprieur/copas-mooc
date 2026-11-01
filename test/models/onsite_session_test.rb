require "test_helper"

class OnsiteSessionTest < ActiveSupport::TestCase
  setup do
    @admin = create_user(role: :admin)
    @session = create_onsite_session(mode: :photo)
    @importer = ParticipantImport.new(@session, invited_by: @admin)
  end

  test "une session intra exige une structure et au moins une demi-journée" do
    session = CourseSession.new(course: @session.course, kind: :intra)
    assert_not session.valid?
    assert session.errors[:organization].any?
    assert_match(/demi-journée/, session.errors[:base].join)
  end

  test "import CSV : comptes créés, invitations, doublons ignorés, lignes invalides signalées" do
    csv = "prenom;nom;email;fonction\nAnne;Martin;anne@ville.fr;Agente d'accueil\nBob;Lenoir;pas-un-courriel;\nAnne;Martin;anne@ville.fr;\n"
    result = @importer.import_csv(csv)
    assert_equal 1, result.created.size
    assert_equal [ "anne@ville.fr" ], result.skipped
    assert_equal 1, result.errors.size
    enrollment = result.created.first
    assert enrollment.onboarding?
    assert_match(/\A\d{4}\z/, enrollment.attendance_code)
    assert_nil enrollment.needs_assessment, "le participant complète lui-même son recueil des besoins"
  end

  test "le parcours ne s'ouvre qu'après le recueil des besoins du participant (ind. 4)" do
    e = @importer.add(first_name: "Anne", last_name: "Martin", email: "anne2@ville.fr")
    e.acknowledge_welcome!
    e.decide_positioning!(e.attempts.create!(assessment: e.course.positioning_assessment).grade!(answers_for(e.course.positioning_assessment)))
    assert e.reload.onboarding?
    e.create_needs_assessment!(job_title: "Agente", work_situations: "Accueil des habitants en mairie annexe", expectations: "Comprendre le budget participatif")
    e.start_if_ready!
    assert e.reload.active?
  end

  test "mode photo : clôture impossible sans photo, sans présences ni signature du formateur" do
    e = @importer.add(first_name: "Anne", last_name: "Martin", email: "anne3@ville.fr")
    slot = @session.slots.first
    slot.open!(by: @admin)
    issues = slot.missing_for_close
    assert issues.any? { _1.include?("photo") }
    assert issues.any? { _1.include?("présent ou absent") }
    assert issues.any? { _1.include?("formateur") }

    slot.attendance_for(e).update!(status: :present, signature_method: :photo_sheet)
    slot.sheet_photos.attach(io: StringIO.new("photo"), filename: "feuille.jpg", content_type: "image/jpeg")
    slot.update!(trainer_signature: "data:image/png;base64,xx", trainer_signed_at: Time.current)
    assert_empty slot.missing_for_close
    slot.close!(by: @admin)
    assert slot.closed?
    assert_equal 3.5, e.reload.attended_hours
  end

  test "une correction après clôture exige un motif et laisse une trace" do
    e = @importer.add(first_name: "Anne", last_name: "Martin", email: "anne4@ville.fr")
    slot = @session.slots.first
    slot.update!(trainer_signed_at: Time.current)
    slot.sheet_photos.attach(io: StringIO.new("photo"), filename: "feuille.jpg", content_type: "image/jpeg")
    slot.attendance_for(e).update!(status: :absent)
    slot.close!(by: @admin)

    attendance = slot.attendances.find_by(enrollment: e)
    attendance.status = :present
    assert_not attendance.save
    attendance.correction_reason = "Arrivée signalée par la structure, feuille papier vérifiée"
    attendance.corrected_by = @admin
    assert attendance.save
    assert e.activity_events.exists?(action: "attendance.corrected")
  end

  test "l'attestation n'est délivrée qu'après la clôture de toutes les demi-journées" do
    e = @importer.add(first_name: "Anne", last_name: "Martin", email: "anne5@ville.fr")
    e.create_needs_assessment!(job_title: "Agente", work_situations: "Accueil des habitants en mairie annexe", expectations: "Comprendre le budget participatif")
    e.acknowledge_welcome!
    e.decide_positioning!(e.attempts.create!(assessment: e.course.positioning_assessment).grade!(answers_for(e.course.positioning_assessment)))
    assert e.final_unlocked?, "l'évaluation finale s'ouvre le premier jour de la session"
    e.complete!(e.attempts.create!(assessment: e.course.final_assessment).grade!(answers_for(e.course.final_assessment)))
    assert_not e.certificate_ready?

    @session.slots.each do |slot|
      slot.attendance_for(e).update!(status: :present, signature_method: :photo_sheet)
      slot.sheet_photos.attach(io: StringIO.new("p"), filename: "f.jpg", content_type: "image/jpeg")
      slot.update!(trainer_signed_at: Time.current)
      slot.close!(by: @admin)
    end
    assert e.reload.certificate_ready?
    assert_equal 7.0, e.attended_hours
    assert CertificatePdf.new(e).render.start_with?("%PDF")
    assert CompletionCertificatePdf.new(@session.reload).render.start_with?("%PDF")
    assert AttendanceSheetPdf.new(@session, signed: true).render.start_with?("%PDF")
    assert @session.completed?
  end

  test "convocations envoyées une seule fois à J-7, rappel à J-1" do
    session = create_onsite_session(slots: [ { date: Date.current + 5, starts_at: "09:00", ends_at: "12:00" } ])
    ParticipantImport.new(session, invited_by: @admin).add(first_name: "Anne", last_name: "Martin", email: "anne6@ville.fr")
    ConvocationJob.perform_now
    ConvocationJob.perform_now
    assert session.reload.convocations_sent_at
    assert_equal 1, ActivityEvent.where(action: "convocation.sent").count
    ConvocationJob.perform_now(today: Date.current + 4)
    assert session.reload.reminders_sent_at
  end

  test "les supports ne sont plus accessibles un an après la session" do
    session = create_onsite_session(slots: [ { date: Date.current - 400, starts_at: "09:00", ends_at: "12:00" } ])
    assert_not session.materials_available?
    assert @session.materials_available?
  end
end

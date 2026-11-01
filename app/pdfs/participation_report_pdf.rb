# Relevé de participation à une formation à distance (dossier de preuve, D6313-3-1) :
# information préalable, activités et dates, temps actif, résultats, échanges tutoraux, relances.
class ParticipationReportPdf < BasePdf
  def initialize(enrollment)
    super()
    @enrollment = enrollment
    @course = enrollment.course
    @user = enrollment.user
  end

  private

  def build
    header "Relevé de participation – formation à distance"
    field "Apprenant", "#{@user.full_name} (#{@user.email})"
    field "Structure", @enrollment.employer_name || @user.organization_name
    field "Formation", @course.title
    field "Financement", Enrollment::FUNDING_LABELS[@enrollment.funding_type]
    field "Convention", @enrollment.convention_reference
    field "Statut", @enrollment.status_label
    field "Demande", date(@enrollment.requested_at)
    field "Analyse du besoin", @enrollment.needs_reviewed_at ? "le #{date(@enrollment.needs_reviewed_at)} par #{@enrollment.needs_reviewed_by&.full_name}" : "à faire"
    field "Livret d'accueil lu", date(@enrollment.welcome_acknowledged_at)
    field "Positionnement", [ Enrollment::POSITIONING_LABELS[@enrollment.positioning_decision], @enrollment.positioning_note ].compact.join(" – ")
    field "Temps actif total mesuré", duration(@enrollment.total_active_seconds)
    field "Progression", "#{@enrollment.progress_percent} % des modules"

    section "Modules"
    progresses = @enrollment.lesson_progresses.index_by(&:lesson_id)
    rows = [ [ "Module", "Durée estimée", "1re consultation", "Terminé le", "Temps actif" ] ]
    @course.lessons.each do |lesson|
      p = progresses[lesson.id]
      rows << [ clean(lesson.title), "#{lesson.estimated_minutes} min", date(p&.first_viewed_at), date(p&.completed_at), duration(p&.active_seconds) ]
    end
    table rows

    section "Évaluations"
    attempts = @enrollment.attempts.submitted.includes(:assessment).order(:submitted_at)
    rows = [ [ "Évaluation", "Date", "Score", "Résultat" ] ]
    attempts.each { |a| rows << [ clean(a.assessment.title), date(a.submitted_at), "#{a.score} %", a.passed ? "Seuil atteint" : "Seuil non atteint" ] }
    rows.size > 1 ? table(rows) : pdf.text("Aucune évaluation rendue.")

    section "Échanges avec l'équipe pédagogique et relances"
    items = @enrollment.support_threads.includes(messages: :author).flat_map(&:messages).map do |m|
      [ m.created_at, m.author.staff? ? "Réponse de l'équipe" : "Question de l'apprenant", m.body ]
    end
    items += @enrollment.reminders.map { |r| [ r.sent_at, r.kind_label, r.message.to_s ] }
    if items.any?
      table([ [ "Date", "Type", "Détail" ] ] + items.sort_by(&:first).map { |t, type, body| [ date(t), clean(type), clean(body.truncate(140)) ] })
    else
      pdf.text "Aucun échange ni relance."
    end

    section "Journal horodaté"
    rows = [ [ "Horodatage", "Événement" ] ]
    @enrollment.activity_events.chronological.where.not(action: "lesson.viewed").each do |e|
      rows << [ I18n.l(e.occurred_at, format: "%d/%m/%Y %H:%M"), clean(e.label) ]
    end
    table rows
  end

  def table(rows)
    pdf.table(rows, width: pdf.bounds.width, header: true, cell_style: { size: 8, padding: [ 4, 5 ], border_color: "D5DDE0" }) do |t|
      t.row(0).font_style = :bold
      t.row(0).background_color = "E3ECEE"
    end
  end
end

# Attestation de fin de formation remise au stagiaire (Code du travail, art. L6353-1, al. 2) :
# objectifs, nature et durée de l'action, résultats de l'évaluation des acquis.
class CertificatePdf < BasePdf
  def initialize(enrollment)
    super()
    @enrollment = enrollment
    @course = enrollment.course
    @user = enrollment.user
    @final = enrollment.final_attempt
  end

  private

  def build
    header "Attestation de fin de formation"
    pdf.fill_color MUTED
    pdf.text clean("N° #{@enrollment.certificate_number}"), size: 9
    pdf.fill_color INK
    pdf.move_down 10

    pdf.text clean("#{org[:name]} atteste que :"), leading: 3
    pdf.move_down 6
    field "Bénéficiaire", @user.full_name
    field "Fonction", @enrollment.needs_assessment&.job_title || @user.job_title
    field "Structure", @enrollment.employer_name || @user.organization_name

    section "Action suivie"
    field "Intitulé", @course.title
    field "Nature de l'action", "Action de formation (art. L6313-1, 1° du Code du travail)"
    if (session = @enrollment.course_session)
      field "Modalité", "Présentiel#{" – #{session.location.name}" if session.location}"
      field "Période", session.dates_label
      field "Durée prévue", "#{format_hours(session.total_hours)} heures"
      field "Durée suivie", "#{format_hours(@enrollment.attended_hours)} heures (feuilles d'émargement)"
    else
      field "Modalité", @course.modality_label
      field "Durée prévue", "#{format_hours(@course.duration_hours)} heures"
      field "Période", "du #{date(@enrollment.started_at)} au #{date(@enrollment.completed_at)}"
      field "Modules réalisés", "#{@enrollment.completed_lesson_ids.size} sur #{@course.lessons.size}"
    end
    field "Reconnaissance", @course.recognition

    section "Objectifs de la formation et résultats de l'évaluation des acquis"
    rows = [ [ "Objectif", "Résultat" ] ]
    @course.objectives.each do |objective|
      rows << [ clean(objective.description), clean(result_for(objective)) ]
    end
    pdf.table(rows, width: pdf.bounds.width, header: true, cell_style: { size: 9, padding: [ 5, 6 ], border_color: "D5DDE0" },
                    column_widths: { 1 => 130 }) do |t|
      t.row(0).font_style = :bold
      t.row(0).background_color = "E3ECEE"
    end
    pdf.move_down 6
    if @final
      field "Évaluation finale", "#{@final.score} % de bonnes réponses le #{date(@final.submitted_at)} (seuil de réussite : #{@course.pass_threshold} %) – #{@final.passed ? 'objectifs atteints' : 'objectifs partiellement atteints'}"
    end
    pdf.move_down 4
    pdf.fill_color MUTED
    pdf.text clean("Méthode d'évaluation : #{@course.evaluation_methods}"), size: 8
    pdf.fill_color INK

    pdf.move_down 28
    pdf.text clean("Fait le #{date(@enrollment.certificate_issued_at)}, pour servir et valoir ce que de droit."), leading: 3
    pdf.move_down 8
    pdf.text clean(org[:signatory_name]), style: :bold
    pdf.text clean(org[:signatory_title])
  end

  def result_for(objective)
    return "Non évalué" unless @final
    return "Évalué globalement" unless @final.objective_scores.key?(objective.id.to_s)

    score = @final.objective_scores[objective.id.to_s]
    "#{@final.objective_acquired?(objective) ? 'Acquis' : 'En cours d’acquisition'} (#{score} %)"
  end

  def format_hours(value) = value.to_f.round(2).to_s.sub(/\.0\z/, "").tr(".", ",")
end

# Certificat de réalisation (arrêté du 21 décembre 2018), une page par participant,
# heures calculées à partir des présences émargées. Mise en page inspirée du modèle ministériel :
# à vérifier avec la dernière version publiée et les exigences de l'OPCO concerné.
class CompletionCertificatePdf < BasePdf
  def initialize(session)
    super()
    @session = session
  end

  private

  def build
    @session.participants.each_with_index do |enrollment, i|
      pdf.start_new_page if i.positive?
      certificate(enrollment)
    end
  end

  def certificate(enrollment)
    header "Certificat de réalisation"
    pdf.text clean("Je soussigné(e) #{org[:signatory_name]}, représentant(e) légal(e) du dispensateur de l'action concourant au développement des compétences #{org[:name]}, atteste que :"), leading: 3
    pdf.move_down 10
    field "Bénéficiaire", enrollment.user.full_name
    field "Employeur", enrollment.employer_name || @session.organization&.name
    pdf.move_down 8
    pdf.text clean("a suivi l'action « #{@session.course.title} »"), style: :bold
    pdf.move_down 8
    field "Nature de l'action", "Action de formation (art. L6313-1, 1° du Code du travail)"
    field "Période", @session.dates_label
    field "Modalité", "Présentiel#{" – #{@session.location.name}" if @session.location}"
    field "Durée prévue", "#{hours(@session.total_hours)} heures"
    field "Durée réalisée", "#{hours(enrollment.attended_hours)} heures, d'après les feuilles d'émargement"
    field "Référence", "Session #{@session.reference}#{" – convention #{@session.convention_reference}" if @session.convention_reference.present?}"
    pdf.move_down 10
    pdf.fill_color MUTED
    pdf.text clean("Les feuilles d'émargement qui fondent ce certificat sont conservées par l'organisme et tenues à la disposition du financeur."), size: 8
    pdf.fill_color INK
    pdf.move_down 24
    pdf.text clean("Fait le #{I18n.l(Date.current, format: :long)}"), leading: 3
    pdf.move_down 8
    pdf.text clean(org[:signatory_name]), style: :bold
    pdf.text clean(org[:signatory_title])
    pdf.text clean("Cachet de l'organisme :")
  end

  def hours(value) = value.to_f.round(2).to_s.sub(/\.0\z/, "").tr(".", ",")
end

require "base64"

# Feuille d'émargement par demi-journée.
# signed: false → feuille pré-remplie à imprimer et faire signer (mode photo) ;
# signed: true  → feuille remplie à partir des présences enregistrées (pour le financeur).
class AttendanceSheetPdf < BasePdf
  def initialize(session, signed:)
    super()
    @pdf = Prawn::Document.new(page_size: "A4", page_layout: :landscape, margin: [ 40, 40, 48, 40 ], info: { Creator: "COPAS Academy" })
    @pdf.font "Helvetica", size: 9
    @session = session
    @signed = signed
  end

  private

  def build
    slots = @session.slots.includes(attendances: :enrollment).to_a
    participants = @session.participants
    slots.each_with_index do |slot, i|
      pdf.start_new_page if i.positive?
      page_header(slot)
      rows = [ [ "Participant", "Fonction / structure", "Signature", "Statut" ] ]
      participants.each do |enrollment|
        attendance = slot.attendances.find { _1.enrollment_id == enrollment.id }
        rows << [ clean(enrollment.user.full_name), clean([ enrollment.needs_assessment&.job_title || enrollment.user.job_title, enrollment.employer_name ].compact_blank.join(" – ")),
                 signature_cell(attendance), clean(@signed ? status_text(attendance) : "") ]
      end
      pdf.table(rows, width: pdf.bounds.width, header: true,
                      column_widths: { 0 => 170, 1 => 210, 3 => 150 },
                      cell_style: { size: 9, padding: [ 6, 6 ], border_color: "9AA5AE", height: 42, valign: :center }) do |t|
        t.row(0).font_style = :bold
        t.row(0).background_color = "E3ECEE"
        t.row(0).height = 22
      end
      trainer_block(slot)
    end
  end

  def page_header(slot)
    pdf.fill_color TEAL
    pdf.text clean("#{org[:name]} – déclaration d'activité n° #{org[:nda]}"), size: 9, style: :bold
    pdf.fill_color INK
    pdf.move_down 6
    pdf.text clean("Feuille d'émargement – #{@session.course.title}"), size: 14, style: :bold
    pdf.move_down 4
    pdf.text clean("#{slot.label}  ·  Lieu : #{[ @session.location&.name, @session.location&.address&.squish ].compact.join(', ').presence || '—'}"), size: 10
    pdf.text clean("Structure : #{@session.organization&.name || '—'}  ·  Session #{@session.reference}  ·  Formation en présentiel  ·  Émargement : #{CourseSession::ATTENDANCE_LABELS[@session.attendance_mode]}"), size: 9
    pdf.move_down 10
  end

  def signature_cell(attendance)
    return "" unless @signed && attendance&.attended?

    if attendance.signature.present?
      { image: StringIO.new(Base64.decode64(attendance.signature.split(",", 2).last)), fit: [ 150, 32 ], position: :center, vposition: :center }
    elsif attendance.signed_at
      clean("Signé en ligne le #{I18n.l(attendance.signed_at, format: '%d/%m/%Y à %H:%M')} (#{Attendance::METHOD_LABELS[attendance.signature_method]})")
    else
      clean(Attendance::METHOD_LABELS[attendance.signature_method].to_s)
    end
  end

  def status_text(attendance)
    return "Absent" if attendance.nil? || attendance.pending? || attendance.absent?

    text = attendance.status_label
    text += " (#{attendance.arrived_at.strftime('%H:%M')})" if attendance.late? && attendance.arrived_at
    text += " (#{attendance.left_at.strftime('%H:%M')})" if attendance.left_early? && attendance.left_at
    text
  end

  def trainer_block(slot)
    pdf.move_down 14
    pdf.text clean("Formateur : #{@session.trainer&.full_name || '—'}"), style: :bold
    if @signed && slot.trainer_signature.present?
      pdf.image StringIO.new(Base64.decode64(slot.trainer_signature.split(",", 2).last)), fit: [ 160, 40 ]
    elsif @signed && slot.trainer_signed_at
      pdf.text clean("Signé en ligne le #{I18n.l(slot.trainer_signed_at, format: '%d/%m/%Y à %H:%M')}")
    else
      pdf.text "Signature :"
      pdf.move_down 30
    end
    if @signed
      pdf.fill_color MUTED
      closing = slot.closed_at ? "clôturée le #{I18n.l(slot.closed_at, format: '%d/%m/%Y à %H:%M')}" : "non clôturée"
      photo = slot.sheet_photos.attached? ? " · Feuille papier signée photographiée le #{I18n.l(slot.sheet_uploaded_at || slot.sheet_photos.first.created_at, format: "%d/%m/%Y à %H:%M")} (conservée dans la plateforme)" : ""
      pdf.text clean("Demi-journée #{closing}#{photo}"), size: 8
      pdf.fill_color INK
    end
  end
end

require "prawn"
require "prawn/table"

# Polices PDF standard (encodage Windows-1252) : le texte est converti par #clean.
Prawn::Fonts::AFM.hide_m17n_warning = true

class BasePdf
  INK = "1B2430"
  TEAL = "0F5C6E"
  MUTED = "5B6675"

  def initialize
    @pdf = Prawn::Document.new(page_size: "A4", margin: [ 56, 56, 64, 56 ], info: { Creator: "COPAS Academy" })
    @pdf.fill_color INK
    @pdf.font "Helvetica", size: 10
  end

  def render
    build
    footer
    @pdf.render
  end

  private

  attr_reader :pdf

  def org = @org ||= Rails.application.config_for(:organization)

  def header(title)
    pdf.fill_color TEAL
    pdf.text clean(org[:name]), size: 11, style: :bold
    pdf.fill_color MUTED
    pdf.text clean("#{org[:legal_form]} – #{org[:address]}"), size: 8
    pdf.text clean("SIRET #{org[:siret]} – Déclaration d'activité n° #{org[:nda]}"), size: 8
    pdf.move_down 28
    pdf.fill_color INK
    pdf.text clean(title), size: 18, style: :bold
    pdf.move_down 14
  end

  def section(title)
    pdf.move_down 12
    pdf.fill_color TEAL
    pdf.text clean(title), size: 11, style: :bold
    pdf.fill_color INK
    pdf.move_down 4
  end

  def field(label, value)
    pdf.formatted_text [ { text: clean("#{label} : "), styles: [ :bold ] }, { text: clean(value.to_s.presence || "—") } ], leading: 2
  end

  def footer
    pdf.number_pages clean("Document généré le #{I18n.l(Time.current, format: :long)} à partir des données horodatées de la plateforme – page <page>/<total>"),
                     at: [ pdf.bounds.left, -20 ], size: 7, color: MUTED
  end

  def date(value) = value ? I18n.l(value.to_date, format: :long) : "—"

  def duration(seconds)
    return "—" if seconds.to_i.zero?

    hours, rest = seconds.to_i.divmod(3600)
    "#{hours} h #{(rest / 60).to_s.rjust(2, '0')}"
  end

  # Les polices PDF standard utilisent l'encodage Windows-1252.
  def clean(text)
    text.to_s.tr("  ", "  ").encode("Windows-1252", invalid: :replace, undef: :replace, replace: "?").encode("UTF-8")
  end

  def plain(rich_text) = rich_text.respond_to?(:to_plain_text) ? rich_text.to_plain_text : rich_text.to_s
end

# Inscription des participants d'une session intra, un par un ou par import CSV
# (colonnes : prenom, nom, email, fonction ; séparateur virgule ou point-virgule).
class ParticipantImport
  Result = Data.define(:created, :skipped, :errors)

  HEADERS = {
    "prenom" => :first_name, "prénom" => :first_name, "first_name" => :first_name,
    "nom" => :last_name, "last_name" => :last_name,
    "email" => :email, "courriel" => :email, "mail" => :email,
    "fonction" => :job_title, "poste" => :job_title, "job_title" => :job_title
  }.freeze

  def initialize(session, invited_by:)
    @session = session
    @invited_by = invited_by
  end

  def import_csv(text)
    text = text.to_s.sub("﻿", "")
    separator = text.lines.first.to_s.count(";") > text.lines.first.to_s.count(",") ? ";" : ","
    rows = CSV.parse(text, headers: true, col_sep: separator)
    created = []
    skipped = []
    errors = []
    rows.each_with_index do |row, i|
      attrs = row.to_h.each_with_object({}) do |(key, value), h|
        field = HEADERS[key.to_s.strip.downcase]
        h[field] = value.to_s.strip if field
      end
      outcome = add(**attrs.slice(:first_name, :last_name, :email, :job_title))
      case outcome
      when Enrollment then created << outcome
      when :already then skipped << attrs[:email]
      else errors << "Ligne #{i + 2} : #{outcome}"
      end
    end
    Result.new(created, skipped, errors)
  rescue CSV::MalformedCSVError => e
    Result.new([], [], [ "Fichier illisible : #{e.message}" ])
  end

  # Renvoie l'inscription créée, :already si la personne est déjà inscrite, ou un message d'erreur.
  def add(first_name:, last_name:, email:, job_title: nil)
    return "courriel manquant ou invalide" unless email.to_s.match?(URI::MailTo::EMAIL_REGEXP)
    return "prénom et nom obligatoires" if first_name.blank? || last_name.blank?

    user = User.find_by(email: email.downcase.strip)
    new_user = user.nil?
    if new_user
      user = User.new(first_name: first_name, last_name: last_name, email: email, job_title: job_title,
                      organization_name: @session.organization&.name, organization_type: @session.organization&.kind,
                      password: SecureRandom.base58(20) + "Aa1", terms_accepted_at: nil)
      user.skip_confirmation!
      user.save!(validate: false)
    end
    return :already if user.enrollments.exists?(course: @session.course)

    enrollment = @session.enrollments.create!(
      user: user, course: @session.course, status: :onboarding, funding_type: @session.funded_by_opco? ? :opco : :employer,
      employer_name: @session.organization&.name, convention_reference: @session.convention_reference,
      requested_at: Time.current, approved_at: Time.current, approved_by: @invited_by, invited_at: Time.current
    )
    enrollment.log!("enrollment.invited", user: @invited_by, subject: @session)
    token = new_user ? user.send(:set_reset_password_token) : nil
    SessionMailer.with(enrollment: enrollment, password_token: token).invitation.deliver_later
    enrollment
  rescue ActiveRecord::RecordInvalid => e
    e.record.errors.full_messages.to_sentence
  end
end

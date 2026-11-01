class ApplicationMailer < ActionMailer::Base
  default from: -> { ENV.fetch("MAIL_FROM", "COPAS Academy <formation@copas.coop>") }
  layout "mailer"
  helper :application

  private

  def team_address = ENV.fetch("TEAM_EMAIL", "formation@copas.coop")
end

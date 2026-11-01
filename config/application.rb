require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module CopasAcademy
  class Application < Rails::Application
    config.load_defaults 8.1
    config.autoload_lib(ignore: %w[assets tasks])

    config.time_zone = "Europe/Paris"
    config.i18n.default_locale = :fr
    config.i18n.available_locales = [ :fr ]

    config.active_job.queue_adapter = :solid_queue

    # Rack::Attack : limitation des tentatives de connexion et des envois de formulaires
    config.middleware.use Rack::Attack
  end
end

source "https://rubygems.org"

ruby file: ".ruby-version"

gem "rails", "~> 8.1.0"
gem "propshaft"
gem "pg", "~> 1.5"
gem "puma", ">= 6.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "tailwindcss-rails", "~> 4.0"
gem "jbuilder"

# Rails 8 : file d'attente, cache et Action Cable adossés à PostgreSQL (pas de Redis)
gem "solid_queue"
gem "solid_cache"
gem "solid_cable"

gem "bootsnap", require: false
gem "thruster", require: false
gem "tzinfo-data", platforms: %i[windows jruby]

# Authentification, autorisations, sécurité
gem "devise", "~> 5.0", ">= 5.0.4"
gem "devise-i18n"
gem "rails-i18n", "~> 8.0"
gem "pundit", "~> 2.4"
gem "rack-attack"

# Fichiers : Active Storage sur stockage objet S3 (Scaleway / OVH, hébergé en France)
gem "aws-sdk-s3", require: false
gem "image_processing", "~> 1.13"

# Documents de preuve (attestation L6353-1, relevé de participation)
gem "prawn", "~> 2.5"
gem "prawn-table"

gem "pagy", "~> 9.0"

# QR codes (émargement, questionnaires en salle) et import CSV des participants
gem "rqrcode", "~> 3.0"
gem "csv"

group :development, :test do
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"
  gem "brakeman", require: false
  gem "bundler-audit", require: false
  gem "rubocop-rails-omakase", require: false
end

group :development do
  gem "web-console"
  gem "letter_opener_web"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end

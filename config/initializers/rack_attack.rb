# Limitation des requêtes : connexion, mot de passe oublié, formulaires publics.
class Rack::Attack
  Rack::Attack.cache.store = Rails.cache

  throttle("connexion/ip", limit: 10, period: 60) do |req|
    req.ip if req.post? && req.path == "/compte/connexion"
  end

  throttle("connexion/email", limit: 6, period: 300) do |req|
    if req.post? && req.path == "/compte/connexion"
      req.params.dig("user", "email").to_s.downcase.strip.presence
    end
  end

  throttle("mot-de-passe/ip", limit: 5, period: 600) do |req|
    req.ip if req.post? && req.path.start_with?("/compte/password", "/compte/unlock", "/compte/confirmation")
  end

  throttle("requetes/ip", limit: 300, period: 60) do |req|
    req.ip unless req.path.start_with?("/assets", "/up")
  end

  self.throttled_responder = lambda do |_req|
    [ 429, { "content-type" => "text/plain; charset=utf-8", "retry-after" => "60" }, [ "Trop de tentatives. Réessayez dans une minute.\n" ] ]
  end
end

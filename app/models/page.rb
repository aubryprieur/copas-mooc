# Pages institutionnelles éditables : livret d'accueil, règlement intérieur, CGU, accessibilité,
# référents, procédure violences et harcèlement, politique de confidentialité, mentions légales.
class Page < ApplicationRecord
  SLUGS = {
    "livret-accueil" => "Livret d'accueil",
    "reglement-interieur" => "Règlement intérieur",
    "cgu" => "Conditions générales d'utilisation et de vente",
    "referents" => "Équipe et référents",
    "accessibilite" => "Accessibilité et handicap",
    "prevention-violences" => "Prévention des violences, du harcèlement et des discriminations",
    "assistance" => "Assistance technique et pédagogique",
    "confidentialite" => "Données personnelles",
    "mentions-legales" => "Mentions légales",
    "indicateurs" => "Nos indicateurs de résultats"
  }.freeze

  has_rich_text :body

  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-z0-9-]+\z/ }

  def to_param = slug

  def self.fetch(slug) = find_by(slug: slug, published: true)
end

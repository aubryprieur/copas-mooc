class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
         :validatable, :confirmable, :lockable, :timeoutable, :trackable

  # apprenant, formateur, administrateur, auditeur (compte observateur en lecture seule, ind. 17)
  enum :role, { learner: 0, trainer: 1, admin: 2, auditor: 3 }, default: :learner
  enum :organization_type, { collectivite: 0, association: 1, etablissement_public: 2, entreprise: 3, particulier: 4 }, prefix: :org

  ORGANIZATION_TYPE_LABELS = {
    "collectivite" => "Collectivité territoriale",
    "association" => "Association",
    "etablissement_public" => "Établissement public / bailleur",
    "entreprise" => "Entreprise",
    "particulier" => "À titre individuel"
  }.freeze

  has_one_attached :avatar do |attachable|
    attachable.variant :thumb, resize_to_fill: [ 96, 96 ]
  end

  has_many :enrollments, dependent: :restrict_with_error
  has_many :courses, through: :enrollments
  has_many :support_threads, dependent: :restrict_with_error
  has_many :complaints, dependent: :nullify
  has_many :trained_courses, class_name: "Course", foreign_key: :trainer_id, dependent: :nullify

  validates :first_name, :last_name, presence: true, length: { maximum: 80 }
  validates :terms_accepted_at, presence: { message: "doit être accepté" }, on: :create
  validate :password_complexity

  attr_accessor :accept_terms
  # Devise :trackable sans conservation des adresses IP (minimisation RGPD)
  attr_accessor :current_sign_in_ip, :last_sign_in_ip

  before_validation :record_terms_acceptance, on: :create

  scope :staff, -> { where(role: %i[trainer admin]) }
  scope :ordered, -> { order(:last_name, :first_name) }

  def full_name = "#{first_name} #{last_name}".strip
  def initials = "#{first_name.to_s[0]}#{last_name.to_s[0]}".upcase
  def staff? = trainer? || admin?
  # L'auditeur voit l'espace de gestion sans pouvoir rien modifier.
  def backoffice? = staff? || auditor?

  def enrollment_for(course) = enrollments.find_by(course: course)

  # Un participant inscrit par sa structure reçoit un lien pour choisir son mot de passe :
  # ce lien reste valable 14 jours tant qu'il ne s'est jamais connecté.
  def reset_password_period_valid?
    return reset_password_sent_at.present? && reset_password_sent_at > 14.days.ago if sign_in_count.zero? && enrollments.where.not(invited_at: nil).exists?

    super
  end

  private

  def record_terms_acceptance
    self.terms_accepted_at ||= Time.current if ActiveModel::Type::Boolean.new.cast(accept_terms)
  end

  def password_complexity
    return if password.blank?
    return if password.length >= 12 && password.match?(/[a-z]/) && password.match?(/[A-Z]/) && password.match?(/\d/)

    errors.add :password, "doit contenir au moins 12 caractères, dont une majuscule, une minuscule et un chiffre"
  end
end

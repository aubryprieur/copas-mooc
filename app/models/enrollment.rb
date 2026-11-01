class Enrollment < ApplicationRecord
  # Parcours : demande -> (validation admin) -> accueil + positionnement -> en formation -> terminée
  enum :status, {
    requested: 0,     # demande déposée avec recueil des besoins (ind. 4)
    onboarding: 1,    # validée : livret d'accueil (ind. 9) et positionnement (ind. 8) à faire
    active: 2,        # parcours ouvert
    completed: 3,     # évaluation finale passée
    abandoned: 4,
    declined: 5
  }, default: :requested

  enum :funding_type, { employer: 0, opco: 1, cnfpt: 2, self_funded: 3, other_funding: 4 }, prefix: :funding
  enum :positioning_decision, { direct_access: 0, adapted_path: 1, referent_contact: 2, redirected: 3 }, prefix: :positioning

  STATUS_LABELS = {
    "requested" => "Demande à étudier", "onboarding" => "Accueil et positionnement", "active" => "En formation",
    "completed" => "Terminée", "abandoned" => "Abandon", "declined" => "Demande refusée"
  }.freeze
  FUNDING_LABELS = {
    "employer" => "Prise en charge par mon employeur (convention)", "opco" => "OPCO (salarié associatif)",
    "cnfpt" => "CNFPT / plan de formation de la collectivité", "self_funded" => "Financement personnel",
    "other_funding" => "Autre financement"
  }.freeze
  POSITIONING_LABELS = {
    "direct_access" => "Accès direct au parcours", "adapted_path" => "Parcours adapté (modules à renforcer)",
    "referent_contact" => "Échange avec le référent pédagogique avant de commencer",
    "redirected" => "Réorientation vers une autre formation"
  }.freeze

  belongs_to :user
  belongs_to :course
  belongs_to :approved_by, class_name: "User", optional: true
  belongs_to :needs_reviewed_by, class_name: "User", optional: true
  belongs_to :course_session, optional: true
  has_many :attendances, dependent: :destroy

  has_one :needs_assessment, dependent: :destroy
  has_many :lesson_progresses, dependent: :destroy
  has_many :attempts, dependent: :destroy
  has_many :activity_events, dependent: :destroy
  has_many :reminders, dependent: :destroy
  has_many :survey_responses, dependent: :destroy
  has_many :support_threads, dependent: :nullify

  accepts_nested_attributes_for :needs_assessment

  validates :user_id, uniqueness: { scope: :course_id, message: "est déjà inscrit à cette formation" }
  # En intra, les participants sont inscrits par leur structure puis complètent eux-mêmes leur recueil des besoins.
  validates :needs_assessment, presence: { message: "doit être renseigné avant toute inscription" }, on: :create,
                               unless: -> { legacy? || course_session_id.present? }
  validates :employer_name, presence: true, if: -> { course_session_id.nil? && (funding_employer? || funding_cnfpt? || funding_opco?) }

  before_create -> { self.attendance_code ||= format("%04d", SecureRandom.random_number(10_000)) }, if: :course_session_id

  before_create { self.requested_at ||= Time.current }

  scope :in_progress, -> { where(status: %i[onboarding active]) }
  scope :inactive_since, ->(time) { active.where("COALESCE(last_activity_at, started_at, approved_at) < ?", time) }

  def status_label = STATUS_LABELS.fetch(status)

  # ---- Progression (ind. 19 ; taux de réalisation asynchrone du guide V10) ----

  def completed_lesson_ids
    @completed_lesson_ids ||= lesson_progresses.where.not(completed_at: nil).pluck(:lesson_id)
  end

  def lesson_completed?(lesson) = completed_lesson_ids.include?(lesson.id)

  def onsite? = course_session_id.present?

  # ---- Présence (formations sur site) ----

  def attended_hours = attendances.includes(:session_slot).sum(&:hours).round(2)
  def planned_hours = course_session&.total_hours.to_f

  def attendance_percent
    return 0 if planned_hours.zero?

    (attended_hours * 100.0 / planned_hours).round
  end

  def progress_percent
    return attendance_percent if onsite?

    total = course.lessons.size
    return 0 if total.zero?

    (completed_lesson_ids.size * 100.0 / total).round
  end

  def total_active_seconds = lesson_progresses.sum(:active_seconds)
  def all_lessons_completed? = course.lessons.any? && completed_lesson_ids.size >= course.lessons.size

  def latest_attempt(assessment) = attempts.where(assessment: assessment).where.not(submitted_at: nil).order(:submitted_at).last
  def positioning_attempt = course.positioning_assessment && latest_attempt(course.positioning_assessment)
  def final_attempt = course.final_assessment && latest_attempt(course.final_assessment)

  def positioning_done? = positioning_attempt.present? || positioning_decision.present?
  def final_unlocked? = active? && (onsite? ? course_session.started? : all_lessons_completed?)
  def hot_survey = survey_responses.find_by(kind: :hot)
  def cold_survey = survey_responses.find_by(kind: :cold)

  def days_inactive
    reference = last_activity_at || started_at || approved_at
    reference ? ((Time.current - reference) / 1.day).floor : nil
  end

  # ---- Transitions, toutes journalisées ----

  def approve!(by:, convention_reference: nil, note: nil)
    transaction do
      update!(status: :onboarding, approved_at: Time.current, approved_by: by,
              convention_reference: convention_reference.presence || self.convention_reference,
              admin_note: note.presence || admin_note)
      log!("enrollment.approved", user: by)
    end
    EnrollmentMailer.with(enrollment: self).approved.deliver_later
  end

  def decline!(by:, note:)
    update!(status: :declined, admin_note: note)
    log!("enrollment.declined", user: by, metadata: { note: note })
    EnrollmentMailer.with(enrollment: self).declined.deliver_later
  end

  def review_needs!(by:, synthesis:)
    update!(needs_synthesis: synthesis, needs_reviewed_at: Time.current, needs_reviewed_by: by)
    log!("needs.reviewed", user: by)
  end

  def acknowledge_welcome!
    return if welcome_acknowledged_at

    update!(welcome_acknowledged_at: Time.current)
    user.update_column(:terms_accepted_at, Time.current) if user.terms_accepted_at.nil?
    log!("welcome.acknowledged")
    if course.positioning_assessment.nil? && positioning_decision.nil?
      update!(positioning_decision: :direct_access, positioning_decided_at: Time.current,
              positioning_note: "Pas de test de positionnement pour cette formation : accès direct, prérequis vérifiés lors de l'analyse du besoin.")
      log!("positioning.decided", metadata: { decision: :direct_access })
    end
    start_if_ready!
  end

  # Règle d'orientation tracée (ind. 8) : seuil de positionnement de la formation.
  def decide_positioning!(attempt)
    decision = attempt.score >= course.positioning_threshold ? :direct_access : :referent_contact
    note = "Décision automatique : score #{attempt.score} % (seuil #{course.positioning_threshold} %)."
    update!(positioning_decision: decision, positioning_note: note, positioning_decided_at: Time.current)
    log!("positioning.decided", metadata: { decision: decision, score: attempt.score })
    start_if_ready!
  end

  def override_positioning!(by:, decision:, note:)
    update!(positioning_decision: decision, positioning_note: note, positioning_decided_at: Time.current)
    log!("positioning.overridden", user: by, metadata: { decision: decision, note: note })
    start_if_ready!
  end

  def start_if_ready!
    return unless onboarding? && welcome_acknowledged_at && positioning_decision.present?
    return if onsite? && needs_assessment.nil?
    return if positioning_redirected?

    update!(status: :active, started_at: Time.current, last_activity_at: Time.current)
    log!("enrollment.started")
  end

  def complete!(attempt)
    return if completed?

    update!(status: :completed, completed_at: Time.current, certificate_number: generate_certificate_number,
            certificate_issued_at: Time.current)
    log!("enrollment.completed", metadata: { final_score: attempt.score, passed: attempt.passed })
    EnrollmentMailer.with(enrollment: self).completed.deliver_later
  end

  def mark_abandoned!(by:, reason:)
    update!(status: :abandoned, abandoned_at: Time.current, abandon_reason: reason)
    log!("enrollment.abandoned", user: by, metadata: { reason: reason })
  end

  # Sur site, l'attestation reprend les heures émargées : elle n'est délivrée qu'une fois la session clôturée.
  def certificate_ready? = completed? && (!onsite? || course_session.all_slots_closed?)

  def touch_activity!
    update_column(:last_activity_at, Time.current)
  end

  def log!(action, user: self.user, subject: nil, metadata: {})
    ActivityEvent.create!(enrollment: self, user: user, action: action, subject: subject,
                          metadata: metadata, occurred_at: Time.current)
  end

  private

  def generate_certificate_number
    "CA-#{Time.current.year}-#{id.to_s.rjust(5, '0')}"
  end
end

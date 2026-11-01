ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module TestFactories
  PASSWORD = "MotDePasse2026".freeze

  def create_user(role: :learner, **attrs)
    @user_seq = (@user_seq || 0) + 1
    User.create!({ first_name: "Prénom", last_name: "Nom#{@user_seq}", email: "u#{@user_seq}-#{SecureRandom.hex(3)}@exemple.fr",
                   password: PASSWORD, role: role, terms_accepted_at: Time.current, confirmed_at: Time.current }.merge(attrs))
  end

  # Formation publiable : fiche complète, 2 objectifs, 2 modules, positionnement et évaluation finale.
  def create_course(**attrs)
    course = Course.create!({
      title: "Formation #{SecureRandom.hex(3)}", summary: "Résumé", target_audience: "Agents", prerequisites: "Aucun prérequis.",
      duration_hours: 3, access_delay: "10 jours", pedagogical_methods: "Vidéos", evaluation_methods: "QCM",
      accessibility: "Sous-titres", pricing_details: "Par personne", funding_options: "Employeur",
      digital_requirements: "Navigateur", support_details: "Sous 2 jours", contact_email: "formation@copas.coop",
      positioning_threshold: 50, pass_threshold: 70
    }.merge(attrs))
    o1 = course.objectives.create!(position: 1, description: "Objectif un")
    o2 = course.objectives.create!(position: 2, description: "Objectif deux")
    course.lessons.create!(title: "Module un", estimated_minutes: 20, position: 1)
    course.lessons.create!(title: "Module deux", estimated_minutes: 20, position: 2)
    pos = course.assessments.create!(kind: :positioning, title: "Positionnement")
    fin = course.assessments.create!(kind: :final, title: "Évaluation finale")
    [ [ pos, o1 ], [ fin, o1 ], [ fin, o2 ] ].each do |assessment, objective|
      assessment.questions.create!(prompt: "Question ?", objective: objective,
                                   choices_attributes: [ { label: "Bonne", correct: true }, { label: "Mauvaise", correct: false } ])
    end
    course.update!(status: :published)
    course
  end

  def request_enrollment(user, course)
    course.enrollments.create!(user: user, funding_type: :employer, employer_name: "Ville",
                               needs_assessment_attributes: { job_title: "CESF", work_situations: "Accompagnement de locataires en impayé",
                                                              expectations: "Savoir monter un dossier FSL complet" })
  end

  def answers_for(assessment, correct: true)
    assessment.questions.to_h { |q| [ q.id.to_s, q.choices.detect { |c| c.correct? == correct }.id.to_s ] }
  end
end

module ActiveSupport
  class TestCase
    parallelize(workers: 1)
    include TestFactories
  end
end

class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  # Rails 8 charge les routes à la demande : Devise a besoin qu'elles le soient.
  setup { Rails.application.reload_routes_unless_loaded }
end

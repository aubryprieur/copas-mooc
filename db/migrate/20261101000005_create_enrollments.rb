class CreateEnrollments < ActiveRecord::Migration[8.1]
  def change
    create_table :enrollments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true
      t.integer :status, null: false, default: 0

      # Demande d'inscription sur devis / convention
      t.integer :funding_type, null: false, default: 0
      t.string :employer_name
      t.string :employer_contact
      t.text :employer_objectives
      t.string :convention_reference
      t.datetime :requested_at
      t.datetime :approved_at
      t.references :approved_by, foreign_key: { to_table: :users }
      t.text :admin_note

      # Indicateur 4 : synthèse de l'analyse du besoin par l'équipe pédagogique
      t.text :needs_synthesis
      t.datetime :needs_reviewed_at
      t.references :needs_reviewed_by, foreign_key: { to_table: :users }

      # Indicateur 9 : livret d'accueil lu
      t.datetime :welcome_acknowledged_at

      # Indicateur 8 : décision de positionnement
      t.integer :positioning_decision
      t.text :positioning_note
      t.datetime :positioning_decided_at

      t.datetime :started_at
      t.datetime :last_activity_at
      t.datetime :completed_at
      t.datetime :abandoned_at
      t.text :abandon_reason
      t.datetime :certificate_issued_at
      t.string :certificate_number
      t.datetime :cold_survey_sent_at

      t.boolean :legacy, null: false, default: false
      t.timestamps
    end
    add_index :enrollments, [ :user_id, :course_id ], unique: true
    add_index :enrollments, :status
    add_index :enrollments, :certificate_number, unique: true

    # Indicateur 4 : recueil nominatif des besoins
    create_table :needs_assessments do |t|
      t.references :enrollment, null: false, foreign_key: true, index: { unique: true }
      t.string :job_title, null: false
      t.text :work_situations, null: false
      t.text :expectations, null: false
      t.text :prior_experience
      t.text :questions
      # Pas de donnée de santé stockée : seulement la demande d'être contacté par le référent handicap
      t.boolean :accommodation_contact_requested, null: false, default: false
      t.timestamps
    end
  end
end

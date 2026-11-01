# Formations sur site (lot 1) : structures clientes, lieux, sessions intra,
# demi-journées, présences (émargement) et demandes de formation des structures.
class CreateOnsiteTraining < ActiveRecord::Migration[8.1]
  def change
    add_column :courses, :delivery, :integer, null: false, default: 0
    add_column :courses, :default_attendance_mode, :integer, null: false, default: 0

    # Structure cliente (commanditaire en intra)
    create_table :organizations do |t|
      t.string :name, null: false
      t.integer :kind, null: false, default: 0
      t.string :contact_name
      t.string :contact_email
      t.string :contact_phone
      t.text :address
      t.timestamps
    end

    # Indicateur 17 : moyens et locaux
    create_table :locations do |t|
      t.string :name, null: false
      t.text :address, null: false
      t.text :access_details
      t.text :accessibility
      t.text :equipment
      t.integer :capacity
      t.timestamps
    end

    # Indicateur 4 : demande et analyse du besoin du commanditaire
    create_table :training_requests do |t|
      t.references :course, null: false, foreign_key: true
      t.references :organization, foreign_key: true
      t.string :organization_name, null: false
      t.integer :organization_kind, null: false, default: 0
      t.string :contact_name, null: false
      t.string :contact_email, null: false
      t.string :contact_phone
      t.string :contact_role
      t.integer :participants_count
      t.string :desired_period
      t.text :participants_profile, null: false
      t.text :structure_objectives, null: false
      t.text :constraints
      t.boolean :accessibility_needs, null: false, default: false
      t.integer :status, null: false, default: 0
      t.text :internal_note
      t.timestamps
    end

    create_table :course_sessions do |t|
      t.references :course, null: false, foreign_key: true
      t.references :organization, foreign_key: true
      t.references :location, foreign_key: true
      t.references :trainer, foreign_key: { to_table: :users }
      t.references :training_request, foreign_key: true
      t.integer :kind, null: false, default: 0
      t.integer :status, null: false, default: 0
      t.integer :attendance_mode, null: false, default: 0
      t.integer :funding_type, null: false, default: 0
      t.string :convention_reference
      t.string :reference, null: false
      t.integer :capacity
      t.text :adapted_program
      t.string :access_token, null: false
      t.datetime :convocations_sent_at
      t.datetime :reminders_sent_at
      t.datetime :closed_at
      t.datetime :client_survey_sent_at
      t.timestamps
    end
    add_index :course_sessions, :reference, unique: true
    add_index :course_sessions, :access_token, unique: true

    # Une ligne par demi-journée : c'est l'unité d'émargement
    create_table :session_slots do |t|
      t.references :course_session, null: false, foreign_key: true
      t.date :date, null: false
      t.time :starts_at, null: false
      t.time :ends_at, null: false
      t.integer :status, null: false, default: 0
      t.string :sign_token, null: false
      t.datetime :opened_at
      t.datetime :closed_at
      t.references :closed_by, foreign_key: { to_table: :users }
      t.text :trainer_signature
      t.datetime :trainer_signed_at
      t.datetime :sheet_uploaded_at
      t.timestamps
    end
    add_index :session_slots, :sign_token, unique: true
    add_index :session_slots, [ :course_session_id, :date, :starts_at ]

    create_table :attendances do |t|
      t.references :enrollment, null: false, foreign_key: true
      t.references :session_slot, null: false, foreign_key: true
      t.integer :status, null: false, default: 0
      t.integer :signature_method
      t.datetime :signed_at
      t.text :signature
      t.time :arrived_at
      t.time :left_at
      t.references :recorded_by, foreign_key: { to_table: :users }
      t.timestamps
    end
    add_index :attendances, [ :enrollment_id, :session_slot_id ], unique: true

    add_reference :enrollments, :course_session, foreign_key: true
    add_column :enrollments, :attendance_code, :string
    add_column :enrollments, :invited_at, :datetime

    # Indicateur 30 : appréciation du commanditaire, sans compte (lien sécurisé)
    create_table :client_surveys do |t|
      t.references :course_session, null: false, foreign_key: true, index: { unique: true }
      t.string :respondent_name
      t.integer :overall_rating, null: false
      t.integer :objectives_rating
      t.integer :organization_rating
      t.integer :trainer_rating
      t.text :observed_effects
      t.text :comment
      t.timestamps
    end
  end
end

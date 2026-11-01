class CreateCourses < ActiveRecord::Migration[8.1]
  def change
    create_table :courses do |t|
      t.string :title, null: false
      t.string :subtitle
      t.string :slug, null: false
      t.integer :status, null: false, default: 0
      t.string :category
      t.integer :level, null: false, default: 0
      t.text :summary

      # Indicateur 1 : information préalable, détaillée et vérifiable
      t.text :target_audience
      t.text :prerequisites
      t.decimal :duration_hours, precision: 5, scale: 1
      t.text :duration_details
      t.text :access_delay
      t.integer :modality, null: false, default: 0
      t.text :pedagogical_methods
      t.text :evaluation_methods
      t.text :accessibility
      t.integer :price_cents
      t.text :pricing_details
      t.text :funding_options
      t.string :recognition, null: false, default: "Attestation de fin de formation (formation non certifiante)"
      t.text :digital_requirements
      t.text :support_details
      t.string :contact_email
      t.datetime :info_updated_at

      t.references :trainer, foreign_key: { to_table: :users }
      t.references :pedagogical_referent, foreign_key: { to_table: :users }

      # Évaluation et suivi
      t.integer :pass_threshold, null: false, default: 70
      t.integer :positioning_threshold, null: false, default: 50
      t.integer :inactivity_reminder_days, null: false, default: 7
      t.integer :inactivity_alert_days, null: false, default: 14

      t.datetime :published_at
      t.integer :legacy_id
      t.timestamps
    end
    add_index :courses, :slug, unique: true
    add_index :courses, :status
  end
end

class CreateTracking < ActiveRecord::Migration[8.1]
  def change
    # Indicateur 19 : effectivité du suivi à distance
    create_table :lesson_progresses do |t|
      t.references :enrollment, null: false, foreign_key: true
      t.references :lesson, null: false, foreign_key: true
      t.datetime :first_viewed_at
      t.datetime :last_viewed_at
      t.datetime :completed_at
      t.integer :active_seconds, null: false, default: 0
      t.timestamps
    end
    add_index :lesson_progresses, [ :enrollment_id, :lesson_id ], unique: true

    create_table :attempts do |t|
      t.references :assessment, null: false, foreign_key: true
      t.references :enrollment, null: false, foreign_key: true
      t.datetime :submitted_at
      t.integer :score
      t.boolean :passed
      t.jsonb :objective_scores, null: false, default: {}
      t.timestamps
    end

    create_table :attempt_answers do |t|
      t.references :attempt, null: false, foreign_key: true
      t.references :question, null: false, foreign_key: true
      t.references :choice, foreign_key: true
      t.boolean :correct, null: false, default: false
      t.timestamps
    end
    add_index :attempt_answers, [ :attempt_id, :question_id ], unique: true

    # Journal horodaté, en ajout seul : source unique des documents de preuve
    create_table :activity_events do |t|
      t.references :enrollment, foreign_key: true
      t.references :user, foreign_key: true
      t.string :action, null: false
      t.references :subject, polymorphic: true
      t.jsonb :metadata, null: false, default: {}
      t.datetime :occurred_at, null: false
    end
    add_index :activity_events, [ :enrollment_id, :occurred_at ]
    add_index :activity_events, :action

    # Indicateurs 10, 12 et 19 : relances tracées
    create_table :reminders do |t|
      t.references :enrollment, null: false, foreign_key: true
      t.integer :kind, null: false, default: 0
      t.references :sent_by, foreign_key: { to_table: :users }
      t.text :message
      t.datetime :sent_at, null: false
      t.timestamps
    end
  end
end

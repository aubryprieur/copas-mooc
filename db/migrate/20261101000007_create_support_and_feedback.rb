class CreateSupportAndFeedback < ActiveRecord::Migration[8.1]
  def change
    # D6313-3-1 et ind. 10/19 : assistance technique et pédagogique tracée
    create_table :support_threads do |t|
      t.references :user, null: false, foreign_key: true
      t.references :enrollment, foreign_key: true
      t.references :lesson, foreign_key: true
      t.integer :category, null: false, default: 0
      t.integer :status, null: false, default: 0
      t.string :subject, null: false
      t.datetime :first_response_at
      t.datetime :closed_at
      t.timestamps
    end
    add_index :support_threads, :status

    create_table :support_messages do |t|
      t.references :support_thread, null: false, foreign_key: true
      t.references :author, null: false, foreign_key: { to_table: :users }
      t.text :body, null: false
      t.timestamps
    end

    # Indicateur 31 : réclamations, difficultés, aléas ; ind. 12 : signalements
    create_table :complaints do |t|
      t.references :user, foreign_key: true
      t.references :course, foreign_key: true
      t.string :reference, null: false
      t.string :name, null: false
      t.string :email, null: false
      t.integer :category, null: false, default: 0
      t.integer :status, null: false, default: 0
      t.text :description, null: false
      t.text :response
      t.text :internal_note
      t.text :improvement_action
      t.datetime :acknowledged_at
      t.datetime :responded_at
      t.datetime :closed_at
      t.references :handled_by, foreign_key: { to_table: :users }
      t.timestamps
    end
    add_index :complaints, :reference, unique: true
    add_index :complaints, :category

    # Indicateur 30 : appréciations à chaud et à froid
    create_table :survey_responses do |t|
      t.references :enrollment, null: false, foreign_key: true
      t.integer :kind, null: false, default: 0
      t.integer :overall_rating, null: false
      t.integer :content_rating
      t.integer :support_rating
      t.integer :platform_rating
      t.integer :objectives_rating
      t.integer :recommend_score
      t.text :applied_in_practice
      t.text :comment
      t.timestamps
    end
    add_index :survey_responses, [ :enrollment_id, :kind ], unique: true

    # Pages institutionnelles : livret d'accueil, règlement, référents, accessibilité, VSS…
    create_table :pages do |t|
      t.string :slug, null: false
      t.string :title, null: false
      t.boolean :published, null: false, default: true
      t.timestamps
    end
    add_index :pages, :slug, unique: true
  end
end

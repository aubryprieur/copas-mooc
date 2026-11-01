class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :first_name, null: false, default: ""
      t.string :last_name, null: false, default: ""
      t.string :email, null: false, default: ""
      t.string :encrypted_password, null: false, default: ""
      t.integer :role, null: false, default: 0
      t.string :job_title
      t.string :organization_name
      t.integer :organization_type
      t.string :phone
      t.text :bio
      t.datetime :terms_accepted_at
      # Référent chargé des signalements (ind. 12) : seul habilité à lire les signalements
      t.boolean :reports_referent, null: false, default: false

      # Devise :recoverable
      t.string :reset_password_token
      t.datetime :reset_password_sent_at
      # Devise :rememberable
      t.datetime :remember_created_at
      # Devise :confirmable
      t.string :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string :unconfirmed_email
      # Devise :lockable
      t.integer :failed_attempts, null: false, default: 0
      t.string :unlock_token
      t.datetime :locked_at
      # Devise :trackable (sans adresse IP : minimisation RGPD)
      t.integer :sign_in_count, null: false, default: 0
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at

      t.integer :legacy_id
      t.timestamps
    end
    add_index :users, :email, unique: true
    add_index :users, :reset_password_token, unique: true
    add_index :users, :confirmation_token, unique: true
    add_index :users, :unlock_token, unique: true
    add_index :users, :role
  end
end

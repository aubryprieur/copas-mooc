class CreateAssessments < ActiveRecord::Migration[8.1]
  def change
    # Positionnement (ind. 8), quiz jalons et évaluation finale (ind. 11, D6313-3-1)
    create_table :assessments do |t|
      t.references :course, null: false, foreign_key: true
      t.references :lesson, foreign_key: true
      t.integer :kind, null: false, default: 0
      t.string :title, null: false
      t.text :instructions
      t.integer :position, null: false, default: 0
      t.timestamps
    end
    add_index :assessments, [ :course_id, :kind ]

    create_table :questions do |t|
      t.references :assessment, null: false, foreign_key: true
      t.references :objective, foreign_key: true
      t.text :prompt, null: false
      t.text :explanation
      t.integer :position, null: false, default: 0
      t.integer :legacy_id
      t.timestamps
    end

    create_table :choices do |t|
      t.references :question, null: false, foreign_key: true
      t.string :label, null: false
      t.boolean :correct, null: false, default: false
      t.integer :position, null: false, default: 0
      t.timestamps
    end
  end
end

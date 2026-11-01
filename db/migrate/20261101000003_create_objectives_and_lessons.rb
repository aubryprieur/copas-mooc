class CreateObjectivesAndLessons < ActiveRecord::Migration[8.1]
  def change
    # Indicateur 5 : objectifs opérationnels et évaluables
    create_table :objectives do |t|
      t.references :course, null: false, foreign_key: true
      t.integer :position, null: false, default: 0
      t.text :description, null: false
      t.text :success_criterion
      t.timestamps
    end

    # Indicateur 6 et D6313-3-1 : déroulé, activités et durée moyenne
    create_table :lessons do |t|
      t.references :course, null: false, foreign_key: true
      t.string :title, null: false
      t.text :summary
      t.integer :position, null: false, default: 0
      t.integer :estimated_minutes, null: false, default: 15
      t.integer :legacy_id
      t.timestamps
    end
    add_index :lessons, [ :course_id, :position ]

    create_table :lesson_objectives do |t|
      t.references :lesson, null: false, foreign_key: true
      t.references :objective, null: false, foreign_key: true
    end
    add_index :lesson_objectives, [ :lesson_id, :objective_id ], unique: true
  end
end

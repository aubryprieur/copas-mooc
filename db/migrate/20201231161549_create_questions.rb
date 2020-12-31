class CreateQuestions < ActiveRecord::Migration[6.0]
  def change
    create_table :questions do |t|
      t.string :question
      t.string :answer
      t.string :distractor_1
      t.string :distractor_2
      t.string :distractor_3
      t.references :workshop, null: false, foreign_key: true

      t.timestamps
    end
  end
end

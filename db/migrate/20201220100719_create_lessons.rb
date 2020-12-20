class CreateLessons < ActiveRecord::Migration[6.0]
  def change
    create_table :lessons do |t|
      t.string :title
      t.text :description
      t.integer :user_id
      t.integer :workshop_id
      t.string :slug
      t.integer :order

      t.timestamps
    end
  end
end

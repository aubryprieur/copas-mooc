class CreateWorkshops < ActiveRecord::Migration[6.0]
  def change
    create_table :workshops do |t|
      t.string :title
      t.string :subtitle
      t.integer :user_id
      t.string :slug
      t.string :difficulty
      t.string :category
      t.string :language
      t.text :description
      t.text :requirements
      t.text :outcomes
      t.string :status
      t.decimal :cost
      t.integer :discount

      t.timestamps
    end
  end
end

class CreateCompletes < ActiveRecord::Migration[6.0]
  def change
    create_table :completes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :completed, polymorphic: true, null: false

      t.timestamps
    end
  end
end

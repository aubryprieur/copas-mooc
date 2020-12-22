class CreateEnrollments < ActiveRecord::Migration[6.0]
  def change
    create_table :enrollments do |t|
      t.references :workshop, index: true
      t.references :user, index: true
      t.timestamps null: false
    end
    add_foreign_key :enrollments, :workshops
    add_foreign_key :enrollments, :users
  end
end

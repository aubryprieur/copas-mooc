class CreateCharges < ActiveRecord::Migration[6.0]
  def change
    create_table :charges do |t|
      t.integer :user_id
      t.string :stripe_charge_id
      t.decimal :amount, precision: 12, scale: 2
    end
  end
end

class CreateCoupons < ActiveRecord::Migration[7.1]
  def change
    create_table :coupons do |t|
      t.string :code
      t.integer :discount
      t.boolean :percentage 
      t.date :expiration_date
      t.boolean :active
      t.references :merchant, foreign_key: true
      t.timestamps
    end
  end
end
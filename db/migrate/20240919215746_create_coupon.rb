class CreateCoupon < ActiveRecord::Migration[7.1]
  def change
    create_table :coupons do |t|
      t.string :code
      t.integer :discount_percentage
      t.date :expiration_date
      t.references :merchant, foreign_key: true

      t.timestamps
    end
  end
end

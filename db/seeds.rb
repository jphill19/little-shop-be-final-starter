# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end


cmd = "pg_restore --verbose --clean --no-acl --no-owner -h localhost -U $(whoami) -d little_shop_development db/data/little_shop_development.pgdump"
puts "Loading PostgreSQL Data dump into local database with command:"
puts cmd
system(cmd)

system("rails db:migrate")

Coupon.create!(code: "SAVE10", discount: 10, expiration_date: Date.new(2025, 12, 31), merchant_id: 4, active: true, percentage:true)
Coupon.create!(code: "SAVE20", discount: 20, expiration_date: Date.new(2025, 12, 31), merchant_id: 4, active: true, percentage:false)
Coupon.create!(code: "SAVE30", discount: 30, expiration_date: Date.new(2025, 12, 31), merchant_id: 4, active: true, percentage:false)
Coupon.create!(code: "SAVE40", discount: 40, expiration_date: Date.new(2025, 12, 31), merchant_id: 4, active: true, percentage:false)
Coupon.create!(code: "SAVE50", discount: 50, expiration_date: Date.new(2025, 12, 31), merchant_id: 4, active: true, percentage:false)
Coupon.create!(code: "SAVE60", discount: 60, expiration_date: Date.new(2025, 12, 31), merchant_id: 4, active: false, percentage:false)
Coupon.create!(code: "OFF30", discount: 30, expiration_date: Date.new(2025, 11, 30), merchant_id: 6, active: true, percentage:true)
Coupon.create!(code: "DISCOUNT15", discount: 15, expiration_date: Date.new(2025, 01, 15), merchant_id: 7, active: true, percentage:false)
Coupon.create!(code: "40DEAL", discount: 40, expiration_date: Date.new(2024, 10, 15), merchant_id: 8, active: true, percentage:true)

Invoice.create(customer_id: 1, merchant_id: 4, status:"returned", coupon_id:1)
Invoice.create(customer_id: 10, merchant_id: 4, status:"shipped", coupon_id:1)
Invoice.create(customer_id: 20, merchant_id: 5, status:"shipped", coupon_id:3)
Invoice.create(customer_id: 30, merchant_id: 6, status:"shipped", coupon_id:4)
Invoice.create(customer_id: 40, merchant_id: 7, status:"packaged", coupon_id:5)

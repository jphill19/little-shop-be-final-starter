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

Coupon.create!(code: "SAVE20", discount_percentage: 20, expiration_date: Date.new(2024, 12, 31), merchant_id: 6)
Coupon.create!(code: "OFF30", discount_percentage: 30, expiration_date: Date.new(2024, 11, 30), merchant_id: 5)

Coupon.create!(code: "DISCOUNT15", discount_percentage: 15, expiration_date: Date.new(2025, 01, 15), merchant_id: 4)
Coupon.create!(code: "40DEAL", discount_percentage: 40, expiration_date: Date.new(2024, 10, 15), merchant_id: 4)

class Coupon < ApplicationRecord
  belongs_to :merchant
  has_many :invoices

  validates :code, presence: true, uniqueness: true
  validates :discount_percentage, presence: true, numericality: { greater_than: 0 }
  validates :expiration_date, presence: true
end
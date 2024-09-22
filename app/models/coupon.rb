class Coupon < ApplicationRecord
  belongs_to :merchant
  has_many :invoices

  validates :merchant, presence: true
  validates :code, presence: true, uniqueness: true
  validates :discount, presence: true, numericality: { greater_than: 0 }
  validates :expiration_date, presence: true
  validates :active, inclusion: [true, false]
  validates :active, exclusion: [nil]
  validates :percentage, inclusion: [true, false]
  validates :percentage, exclusion: [nil]

  validate :merchant_coupon_limits
  validate :expiration_date_past_due

  def self.coupons_sorted_active_true(sort)
    return all unless sort == "true"
    order(active: :desc)
  end

  def self.coupons_sorted_active_false(sort)
    return all unless sort == "false"
    order(active: :asc)
  end

  def invoice_count
    self.invoices.count
  end

  def packaged_invoices?
    self.invoices.where(status: "packaged").any?
  end

  private

  def expiration_date_past_due
    if  expiration_date.present? && expiration_date < Date.today
      errors.add(:expiration_date, "Coupon is past due")
    end
  end

  def merchant_coupon_limits
    if active? && merchant.present? && merchant.coupons.where(active: true).count >= 5
      errors.add(:limit, "Merchant cannot have more than 5 active coupons.")
    end
  end

end
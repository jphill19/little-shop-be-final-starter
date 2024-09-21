class Coupon < ApplicationRecord
  belongs_to :merchant
  has_many :invoices

  validates :code, presence: true, uniqueness: true
  validates :discount, presence: true, numericality: { greater_than: 0 }
  validates :expiration_date, presence: true
  validate  :expiration_date_past_due
  validates :active, inclusion: [true, false]
  validates :active, exclusion: [nil]
  validates :percentage, inclusion: [true, false]
  validates :percentage, exclusion: [nil]


  def invoice_count
    self.invoices.count
  end

  private

  def expiration_date_past_due
    if  expiration_date.present? && expiration_date < Date.today
      errors.add(:expiration_date, "Coupon is past due")
    end
  end
end
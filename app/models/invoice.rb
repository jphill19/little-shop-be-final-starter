class Invoice < ApplicationRecord
  belongs_to :coupon, optional: true
  belongs_to :customer
  belongs_to :merchant
  has_many :invoice_items, dependent: :destroy
  has_many :transactions, dependent: :destroy

  validates :status, inclusion: { in: ["shipped", "packaged", "returned"] }
  validate :coupon_belongs_to_merchant

  private
  
  def coupon_belongs_to_merchant
    return if self.coupon == nil && !invoice_items.any?

    coupon_used = self.coupon

    items_matching_merchant_id_count = invoice_items
                                                    .joins(:item)
                                                    .where(items: { merchant_id: coupon_used.merchant_id})
                                                    .count

    if items_matching_merchant_id_count != invoice_items.count
      errors.add(:wrong_merchant, "A merchant coupon can only be applied to items that belong to the merchant")
    end
  end

end
class MerchantSerializer
  include JSONAPI::Serializer
  attributes :name, :coupons_count, :invoice_coupon_count

  attribute :coupons_count do |merchant|
    merchant.coupons_count
  end

  attribute :invoice_coupon_count do |merchant|
    merchant.invoice_coupons_count
  end

  attribute :item_count, if: Proc.new { |merchant, params|
    params && params[:count] == true
  } do |merchant|
    merchant.item_count
  end
end

class CouponSerializer
  include JSONAPI::Serializer
  attributes :code, :discount, :expiration_date, :active, :percentage

  attribute :times_used, if: proc { |coupon, param| param && param[:invoice_count]} do |coupon|
    coupon.invoice_count
  end
end

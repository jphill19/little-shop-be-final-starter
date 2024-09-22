class InvoiceSerializer
  include JSONAPI::Serializer
  attributes :merchant_id, :customer_id,  :coupon_id, :status

  attribute :coupon_id, if: Proc.new {|invoice| invoice.coupon} do |invoice|
    invoice.coupon.id
  end
end
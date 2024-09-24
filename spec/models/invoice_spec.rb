require "rails_helper"

RSpec.describe Invoice do
  describe "validations" do
    it { should belong_to :merchant }
    it { should belong_to :customer }
    it { should validate_inclusion_of(:status).in_array(%w(shipped packaged returned)) }
    it { should belong_to(:coupon).optional }
  end

  describe "coupon_belongs_to_merchant" do
    it "can create Invoices where coupons & items do not belong to a Merchant" do
      merchant_1 = Merchant.create!(name: "Test")

      customer = Customer.create!(first_name: "John", last_name: "Hill")

      coupon = Coupon.create!(code: "SAVE10", discount: 10, expiration_date: Date.tomorrow, merchant: merchant_1, active: true, percentage: true)
      
      invoice = Invoice.create!(customer: customer, merchant: merchant_1, status:"packaged", coupon: coupon)
      
      item =  Item.create!(name: "Test", description: "Test Item", unit_price: 42.91, merchant: merchant_1)
      
      invoice_items = InvoiceItem.create!(item: item, invoice: invoice, quantity: 5, unit_price: 42.91)

      expect(invoice.valid?).to be true
    end
    
    it "can't create Invoices where coupons & items do not belong to a Merchant" do
      merchant_1 = Merchant.create!(name: "Test")
      merchant_2 = Merchant.create!(name: "Test")

      customer = Customer.create!(first_name: "John", last_name: "Hill")

      coupon = Coupon.create!(code: "SAVE10", discount: 10, expiration_date: Date.tomorrow, merchant: merchant_1, active: true, percentage: true)
      
      invoice = Invoice.create!(customer: customer, merchant: merchant_1, status:"packaged", coupon: coupon)
      
      item =  Item.create!(name: "Test", description: "Test Item", unit_price: 42.91, merchant: merchant_2)
      
      invoice_items = InvoiceItem.create!(item: item, invoice: invoice, quantity: 5, unit_price: 42.91)

      expect(invoice.valid?).to be false
      expect(invoice.errors[:wrong_merchant]).to include("A merchant coupon can only be applied to items that belong to the merchant")
    end
  end
end
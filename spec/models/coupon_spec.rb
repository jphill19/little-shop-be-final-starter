require 'rails_helper'

describe Coupon, type: :model do
  before(:each) do
    Merchant.destroy_all
    Coupon.destroy_all
  end
  
  describe 'relationships' do
    it { should belong_to :merchant }
    it { should have_many(:invoices) }
  end

  describe 'validations' do
    it { should validate_presence_of(:merchant) }

    it { should validate_presence_of(:code) }
    it { should validate_uniqueness_of(:code)}

    it { should validate_presence_of(:discount) }
    it { should validate_numericality_of(:discount).is_greater_than(0) }

    it { should validate_presence_of(:expiration_date) }

    it { should_not allow_value(nil).for(:percentage) }

    it { should_not allow_value(nil).for(:active) }
  end

  describe "expiration_date validation" do
    before(:each) do
      @merchant = Merchant.create(name: "Test")
    end

    it 'does not create a coupon if expiration_date is in the past' do
      coupon = Coupon.create(code: "SAVE10", discount: 10, expiration_date: Date.today.prev_month, merchant: @merchant, active: true, percentage:true)
      
      expect(coupon.valid?).to be(false)
      expect(coupon.errors[:expiration_date]).to include("Coupon is past due")
      expect(Coupon.count).to eq(0)
    end

    it 'creates a coupon if expiration_date is in the future' do
      coupon = Coupon.create(code: "SAVE10", discount: 10, expiration_date: Date.tomorrow, merchant: @merchant, active: true, percentage:true)
      
      expect(coupon.valid?).to be(true)
      expect(coupon.errors[:expiration_date]).to be_empty
    end

    it 'creates a coupon if expiration_date is not present' do
      coupon = Coupon.create(code: "SAVE10", discount: 10, expiration_date: nil, merchant: @merchant, active: true, percentage:true)
      
      expect(coupon.valid?).to be(false)
      expect(coupon.errors[:expiration_date]).to include("can't be blank")
      expect(Coupon.count).to eq(0)
    end
  end

  describe "percentage validation" do
    before(:each) do
      @merchant = Merchant.create(name: "Test")
    end

    it 'is valid when percentage is true' do
      coupon = Coupon.create(code: "SAVE10", discount: 10, expiration_date: Date.tomorrow, merchant: @merchant, active: true, percentage: true)
      expect(coupon.valid?).to be(true)
      expect(coupon.errors[:percentage]).to be_empty
    end

    it 'is valid when percentage is false' do
      coupon =  Coupon.create(code: "SAVE10", discount: 10, expiration_date: Date.tomorrow, merchant: @merchant, active: true, percentage: false)
      
      expect(coupon.valid?).to be(true)
      expect(coupon.errors[:percentage]).to be_empty
    end

    it 'does not create a coupon when percentage is nil' do
      coupon = Coupon.create(code: "SAVE10", discount: 10, expiration_date: Date.tomorrow, merchant: @merchant, active: true, percentage: nil)

      expect(coupon.valid?).to be(false)
      expect(coupon.errors[:percentage]).to include("is not included in the list")
    end
  end

  describe "active validation" do
    before(:each) do
      @merchant = Merchant.create(name: "Test")
    end
  
    it 'is valid when active is true' do
      coupon = Coupon.create(code: "SAVE10", discount: 10, expiration_date: Date.tomorrow, merchant: @merchant, active: true, percentage: true)
      expect(coupon.valid?).to be(true)
      expect(coupon.errors[:active]).to be_empty
    end
  
    it 'is valid when active is false' do
      coupon = Coupon.create(code: "SAVE10", discount: 10, expiration_date: Date.tomorrow, merchant: @merchant, active: false, percentage: true)
      
      expect(coupon.valid?).to be(true)
      expect(coupon.errors[:active]).to be_empty
    end
  
    it 'does not create a coupon when active is nil' do
      coupon = Coupon.create(code: "SAVE10", discount: 10, expiration_date: Date.tomorrow, merchant: @merchant, active: nil, percentage: true)
  
      expect(coupon.valid?).to be(false)
      expect(coupon.errors[:active]).to include("is not included in the list")
    end
  end

  describe "invoice_count" do
    it "returns a count of all invoices associated with a coupon" do
      merchant = Merchant.create(name: "Test")
      customer = Customer.create(first_name: "John", last_name: "Hill")
      coupon = Coupon.create(code: "SAVE10", discount: 10, expiration_date: Date.tomorrow, merchant: merchant, active: true, percentage: true)

      invoice_1 = Invoice.create(customer: customer, merchant: merchant, status:"returned", coupon: coupon)
      invoice_2 = Invoice.create(customer: customer, merchant: merchant, status:"shipped", coupon: coupon)

      expect(coupon.invoice_count).to eq(2)
    end
  end

  describe "merchant_coupon_limits" do
    before(:each) do
      @merchant = Merchant.create(name: "Test")
      @coupon_1 = Coupon.create(code: "SAVE10", discount: 10, expiration_date: Date.tomorrow, merchant: @merchant, active: true, percentage: true)
      @coupon_2 = Coupon.create(code: "SAVE20", discount: 10, expiration_date: Date.tomorrow, merchant: @merchant, active: true, percentage: true)
      @coupon_3 = Coupon.create(code: "SAVE30", discount: 10, expiration_date: Date.tomorrow, merchant: @merchant, active: true, percentage: true)
      @coupon_4 = Coupon.create(code: "SAVE40", discount: 10, expiration_date: Date.tomorrow, merchant: @merchant, active: true, percentage: true)
      @coupon_5 = Coupon.create(code: "SAVE50", discount: 10, expiration_date: Date.tomorrow, merchant: @merchant, active: true, percentage: true)
    end

    it "a merchant can't have more than 5 active coupons" do
      new_coupon = Coupon.new(code: "SAVE60", discount: 10, expiration_date: Date.tomorrow, merchant: @merchant, active: true, percentage: true)

      expect(new_coupon.valid?).to be(false)
      expect(new_coupon.errors[:limit]).to include('Merchant cannot have more than 5 active coupons.')
    end

    it "a merchant can have more than 5 coupons as long as they're inactive" do
      new_coupon = Coupon.create(code: "SAVE70", discount: 10, expiration_date: Date.tomorrow, merchant: @merchant, active: false, percentage: true)

      expect(new_coupon.valid?).to be(true)
      expect(Coupon.count).to eq(6)
    end

    it "does not allow a coupon to be changed to active it exceeds the limit" do
      new_coupon = Coupon.create(code: "SAVE70", discount: 10, expiration_date: Date.tomorrow, merchant: @merchant, active: false, percentage: true)

      new_coupon.active = true

      expect(new_coupon.valid?).to be(false)
      expect(new_coupon.errors[:limit]).to include('Merchant cannot have more than 5 active coupons.')
    end
  end

  describe "packaged_invoices" do
    before(:each) do
      @merchant = Merchant.create(name: "Test")
      @customer = Customer.create(first_name: "John", last_name: "Hill")
      @coupon_1 = Coupon.create(code: "SAVE10", discount: 10, expiration_date: Date.tomorrow, merchant: @merchant, active: true, percentage: true)
      @coupon_2 = Coupon.create(code: "SAVE20", discount: 10, expiration_date: Date.tomorrow, merchant: @merchant, active: true, percentage: true)
      @invoice_1 = Invoice.create(customer: @customer, merchant: @merchant, status:"returned", coupon: @coupon_1)
      @invoice_2 = Invoice.create(customer: @customer, merchant: @merchant, status:"packaged", coupon: @coupon_2)
    end
    it "will return true if a coupon has a packaged invoice" do
      expect(@coupon_2.packaged_invoices?).to be(true)
    end

    it "will return false if a coupon doesn't have packaged invoice"do
      expect(@coupon_1.packaged_invoices?).to be(false)
    end
  end
end
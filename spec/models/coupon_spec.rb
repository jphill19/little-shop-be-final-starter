require 'rails_helper'

describe Coupon, type: :model do
  describe 'relationships' do
    it { should belong_to :merchant }
    it { should have_many(:invoices) }
  end

  describe 'validations' do
    it { should validate_presence_of(:code) }
    it { should validate_uniqueness_of(:code)}

    it { should validate_presence_of(:discount) }
    it { should validate_numericality_of(:discount).is_greater_than(0) }

    it { should validate_presence_of(:expiration_date) }

    #it { should validate_inclusion_of(:percentage).in_array([true, false]) } => Current errors with shoulda matchers validation test
    it { should_not allow_value(nil).for(:percentage) }

    # it { should validate_inclusion_of(:active).in_array([true, false]) }  => Current errors with shoulda matchers validation test
    it { should_not allow_value(nil).for(:active) }
  end

  describe "expiration_date validation" do
    before(:each) do
      @merchant = Merchant.create(name: "Test")
    end

    it 'does not create a coupon if expiration_date is in the past' do
      coupon = Coupon.create(code: "SAVE10", discount: 10, expiration_date: Date.yesterday, merchant: @merchant, active: true, percentage:true)
      
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
end
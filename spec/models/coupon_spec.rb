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

    it { should validate_presence_of(:percentage) }
    it { should validate_inclusion_of(:percentage).in_array([true, false]) }
    it { should_not allow_value(nil).for(:percentage) }

    it { should validate_presence_of(:active) }
    it { should validate_inclusion_of(:active).in_array([true, false]) }
    it { should_not allow_value(nil).for(:active) }
  end

  describe "expiration_date validation" do
    it 'does not create a coupon if expiration_date is in the past' do
      coupon = Coupon.create(code: "SAVE10", discount: 10, expiration_date: Date.yesterday, merchant_id: 4, active: true, percentage:true)

      expect(coupon.errors[:expiration_date]).to include("Coupon is past due")
      expect(Coupon.count).to eq(0)
    end

    it 'creates a coupon if expiration_date is in the future' do
      coupon = Coupon.create(code: "SAVE10", discount: 10, expiration_date: Date.tomorrow, merchant_id: 4, active: true, percentage:true)

      expect(coupon.errors[:expiration_date]).to be_empty
    end

    it 'creates a coupon if expiration_date is not present' do
      coupon = Coupon.create(code: "SAVE10", discount: 10, expiration_date: nil, merchant_id: 4, active: true, percentage:true)

      expect(coupon.errors[:expiration_date]).to include("can't be blank")
      expect(Coupon.count).to eq(0)
    end
  end
end
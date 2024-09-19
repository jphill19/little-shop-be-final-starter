require 'rails_helper'

describe Coupon, type: :model do
  describe 'relationships' do
    it { should belong_to :merchant }
    it { should have_many(:invoices) }
    it 
  end

  describe 'validations' do
    it { should validate_presence_of(:code) }
    it { should validate_uniqueness_of(:code)}
    it { should validate_presence_of(:discount_percentage) }
    it { should validate_numericality_of(:discount_percentage).is_greater_than(0) }
    it { should validate_presence_of(:expiration_date) }
  end

end
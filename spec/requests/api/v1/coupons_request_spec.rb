require "rails_helper"

describe "Merchant endpoints", :type => :request do
  describe "show" do
    before(:each) do
      @merchant = Merchant.create(name: "Test")
      @customer = Customer.create(first_name: "John", last_name: "Hill")
      @coupon = Coupon.create(code: "SAVE10", discount: 10, expiration_date: Date.tomorrow, merchant: @merchant,  active: true,  percentage: true)
      @invoice_1 = Invoice.create(customer: @customer, merchant: @merchant, status: "returned", coupon: @coupon)
      @invoice_2 = Invoice.create(customer: @customer, merchant: @merchant, status: "shipped", coupon: @coupon)
    end

    it "can handle happy paths for proper requests" do
      get "/api/v1/coupons/#{@coupon.id}"
      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:ok)
      expect(json[:data]).to include(:id, :type, :attributes)
      expect(json[:data][:id]).to eq("#{@coupon.id}")
      expect(json[:data][:type]).to eq("coupon")
      expect(json[:data][:attributes][:code]).to eq(@coupon.code)
      expect(json[:data][:attributes][:discount]).to eq(@coupon.discount)
      expect(json[:data][:attributes][:expiration_date]).to eq(@coupon.expiration_date.to_s)
      expect(json[:data][:attributes][:active]).to eq(@coupon.active)
      expect(json[:data][:attributes][:percentage]).to eq(@coupon.percentage)
      expect(json[:data][:attributes][:times_used]).to eq(2)
    end

    it "can handle sad paths for request with ids that exist" do
      get "/api/v1/coupons/#{@coupon.id + 1}"
      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:not_found)
      expect(json).to include(:errors)
      expect(json[:errors][0][:status]).to eq(404)
      expect(json[:errors][0][:message]).to eq("Couldn't find Coupon with 'id'=#{@coupon.id + 1}")
    end

    it "can handle sad paths for request with ids that are not integers" do
      get "/api/v1/coupons/dog"
      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:not_found)
      expect(json).to include(:errors)
      expect(json[:errors][0][:status]).to eq(404)
      expect(json[:errors][0][:message]).to eq("Couldn't find Coupon with 'id'=dog")
    end
  end
end
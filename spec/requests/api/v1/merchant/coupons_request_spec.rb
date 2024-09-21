require "rails_helper"

RSpec.describe "Merchant customers endpoints" do 

  describe "index" do
    before(:each) do
      Merchant.destroy_all
      Coupon.destroy_all
      @merchant_1 = Merchant.create(name: "Test")
      @coupon_1 = Coupon.create(code: "SAVE10", discount: 10, expiration_date: Date.tomorrow, merchant: @merchant_1,  active: true,  percentage: true)
      @coupon_2 = Coupon.create(code: "SAVE20", discount: 10, expiration_date: Date.tomorrow, merchant: @merchant_1,  active: true,  percentage: true)
  
      @merchant_2 = Merchant.create(name: "Test")
      @coupon_3 = Coupon.create(code: "SAVE30", discount: 10, expiration_date: Date.tomorrow, merchant: @merchant_2,  active: true,  percentage: true)
  
    end
    it "it can handle happy paths" do
      get "/api/v1/merchants/#{@merchant_1.id}/coupons"

      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to be_successful
      expect(json[:data].count).to eq(2)
    
      expect(json[:data][0][:id]).to eq(@coupon_1.id.to_s)
      expect(json[:data][0][:type]).to eq("coupon")
      expect(json[:data][0][:attributes][:code]).to eq(@coupon_1.code)
      expect(json[:data][0][:attributes][:discount]).to eq(@coupon_1.discount)
      expect(json[:data][0][:attributes][:expiration_date]).to eq(@coupon_1.expiration_date.to_s)
      expect(json[:data][0][:attributes][:active]).to eq(@coupon_1.active)
      expect(json[:data][0][:attributes][:percentage]).to eq(@coupon_1.percentage)
    
      expect(json[:data][1][:id]).to eq(@coupon_2.id.to_s)
      expect(json[:data][1][:type]).to eq("coupon")
      expect(json[:data][1][:attributes][:code]).to eq(@coupon_2.code)
      expect(json[:data][1][:attributes][:discount]).to eq(@coupon_2.discount)
      expect(json[:data][1][:attributes][:expiration_date]).to eq(@coupon_2.expiration_date.to_s)
      expect(json[:data][1][:attributes][:active]).to eq(@coupon_2.active)
      expect(json[:data][1][:attributes][:percentage]).to eq(@coupon_2.percentage)
    end
    it "can handle sad paths for request with ids that exist" do
      get "/api/v1/merchants/#{@merchant_2.id + 1}/coupons"
      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:not_found)
      expect(json).to include(:errors)
      expect(json[:errors][0][:status]).to eq(404)
      expect(json[:errors][0][:message]).to eq("Couldn't find Merchant with 'id'=#{@merchant_2.id + 1}")
    end

    it "can handle sad paths for request with ids that are not integers" do
      get "/api/v1/merchants/dog/coupons"
      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:not_found)
      expect(json).to include(:errors)
      expect(json[:errors][0][:status]).to eq(404)
      expect(json[:errors][0][:message]).to eq("Couldn't find Merchant with 'id'=dog")
    end
  end
end

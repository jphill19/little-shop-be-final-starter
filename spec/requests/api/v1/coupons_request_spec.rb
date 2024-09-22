require "rails_helper"

describe "Merchant endpoints", :type => :request do
  before(:each) do
    Merchant.destroy_all
    Customer.destroy_all
    Coupon.destroy_all
    @merchant = Merchant.create(name: "Test")
    @customer = Customer.create(first_name: "John", last_name: "Hill")
    @coupon_1 = Coupon.create(code: "SAVE10", discount: 10, expiration_date: Date.tomorrow, merchant: @merchant,  active: true,  percentage: true)
    @coupon_2 = Coupon.create(code: "SAVE20", discount: 10, expiration_date: Date.tomorrow, merchant: @merchant,  active: true,  percentage: true)
    @invoice_1 = Invoice.create(customer: @customer, merchant: @merchant, status: "returned", coupon: @coupon_1)
    @invoice_2 = Invoice.create(customer: @customer, merchant: @merchant, status: "shipped", coupon: @coupon_1)
    @invoice_2 = Invoice.create(customer: @customer, merchant: @merchant, status: "packaged", coupon: @coupon_2)
    
  end
  describe "show" do
    it "can handle happy paths for proper requests" do
      get "/api/v1/coupons/#{@coupon_1.id}"
      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:ok)
      expect(json[:data]).to include(:id, :type, :attributes)
      expect(json[:data][:id]).to eq("#{@coupon_1.id}")
      expect(json[:data][:type]).to eq("coupon")
      expect(json[:data][:attributes][:code]).to eq(@coupon_1.code)
      expect(json[:data][:attributes][:discount]).to eq(@coupon_1.discount)
      expect(json[:data][:attributes][:expiration_date]).to eq(@coupon_1.expiration_date.to_s)
      expect(json[:data][:attributes][:active]).to eq(@coupon_1.active)
      expect(json[:data][:attributes][:percentage]).to eq(@coupon_1.percentage)
      expect(json[:data][:attributes][:times_used]).to eq(2)
    end

    it "can handle sad paths for request with ids that exist" do
      get "/api/v1/coupons/#{@coupon_2.id + 1}"
      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:not_found)
      expect(json).to include(:errors)
      expect(json[:errors][0][:status]).to eq(404)
      expect(json[:errors][0][:message]).to eq("Couldn't find Coupon with 'id'=#{@coupon_2.id + 1}")
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

  describe "deactivate" do
    it "can deactivate an activated coupon" do
      patch "/api/v1/coupons/#{@coupon_1.id}/deactivate"
      json = JSON.parse(response.body, symbolize_names: true)

      expect(response). to have_http_status(:ok)
      expect(response).to have_http_status(:ok)
      expect(json[:data]).to include(:id, :type, :attributes)
      expect(json[:data][:id]).to eq("#{@coupon_1.id}")
      expect(json[:data][:type]).to eq("coupon")
      expect(json[:data][:attributes][:code]).to eq(@coupon_1.code)
      expect(json[:data][:attributes][:discount]).to eq(@coupon_1.discount)
      expect(json[:data][:attributes][:expiration_date]).to eq(@coupon_1.expiration_date.to_s)
      expect(json[:data][:attributes][:active]).to eq(false)
      expect(json[:data][:attributes][:percentage]).to eq(@coupon_1.percentage)
    end

    it "can't deactivate a coupon for an invoice that is packaged" do
      patch "/api/v1/coupons/#{@coupon_2.id}/deactivate"
      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json).to include(:errors)
      expect(json[:errors][0][:status]).to eq(422)
      expect(json[:errors][0][:message]).to eq("Cannot Process Request. Coupon is attached to a packaged Invoice")
    end

    it "can handle sad paths where the id doesn't exsist" do
      patch "/api/v1/coupons/dog/deactivate"
      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:not_found)
      expect(json).to include(:errors)
      expect(json[:errors][0][:status]).to eq(404)
      expect(json[:errors][0][:message]).to eq("Couldn't find Coupon with 'id'=dog")
    end
  end
end
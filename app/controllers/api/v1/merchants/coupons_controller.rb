class Api::V1::Merchants::CouponsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :error_request_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :error_invalid_request

  def index
    merchant = Merchant.find(params[:merchant_id])
    coupons = merchant.coupons

    render json: CouponSerializer.new(coupons)
  end

  def create
    merchant = Merchant.find(params[:merchant_id])
    coupon = merchant.coupons.create!(coupon_params)
    render json: CouponSerializer.new(coupon), status: :created
  end

  private 

  def coupon_params
    params.require(:coupon).permit(:code, :discount, :expiration_date, :active, :percentage)
  end

  def error_request_not_found(error)
    render json: ErrorSerializer.json_singe_error(error, 404), status: :not_found
  end

  def error_invalid_request(errors)
    render json: ErrorSerializer.json_errors_for_invalid_request(errors.record.errors.full_messages), status: :unprocessable_entity
  end
end
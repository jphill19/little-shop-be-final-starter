class Api::V1::Merchants::CouponsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :error_request_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :error_invalid_request

  def index
    merchant = Merchant.find(params[:merchant_id])
    coupons = merchant.coupons

    render json: CouponSerializer.new(coupons)
  end

  private 

  def error_request_not_found(exception)
    render json: ErrorSerializer.json_errors_for_not_found(exception), status: :not_found
  end

  def error_invalid_request(exception)
    render json: ErrorSerializer.json_errors(exception.record.errors), status: :unprocessable_entity
  end
end
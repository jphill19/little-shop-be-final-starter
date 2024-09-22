class Api::V1::CouponsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :error_request_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :error_invalid_request

  def show
    coupon = Coupon.find(params[:id])
    render json: CouponSerializer.new(coupon, params:{invoice_count: true })
  end

  def deactivate
    coupon = Coupon.find(params[:coupon_id])
    if coupon.packaged_invoices?
      message = "Cannot Process Request. Coupon is attached to a packaged Invoice"
      return render json: ErrorSerializer.json_singe_error(message, 422), status: :unprocessable_entity
    end
    coupon.update!(active: false)
    render json: CouponSerializer.new(coupon)
  end

  private 

  def error_request_not_found(error)
    render json: ErrorSerializer.json_singe_error(error, 404), status: :not_found
  end

  def error_invalid_request(errors)
    render json: ErrorSerializer.json_errors_for_invalid_request(errors.record.errors.full_messages), status: :unprocessable_entity
  end
end
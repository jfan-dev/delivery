class OrdersController < ApplicationController
  skip_forgery_protection
  before_action :authenticate!
  before_action :only_buyers!
  
  def create
    @order = Order.new(order_params) { |o| o.buyer = current_user }
    if @order.save
      render json: { message: "Order created successfully", order: @order }, status: :created
    else
      render json: {errors: @order.errors, status: :unprocessable_entity}
    end
  end

  def index
    @orders = Order.where(buyer: current_user)
    render json: {orders: @orders}
  end

  private

  def order_params
    params.require(:order).permit(:store_id, order_items_attributes: [:product_id, :quantity])
  end

  def only_buyers!
    unless current_user&.buyer?
      render json: { message: "Not authorized" }, status: :unauthorized
    end
  end
end
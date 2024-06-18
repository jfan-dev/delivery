class CartsController < ApplicationController
  before_action :authenticate!
  before_action :set_cart, only: [:show, :add_item, :remove_item, :checkout]

  def show
    render json: @cart, include: :order_items
  end

  def add_item
    product = Product.find(params[:product_id])
    @cart.add_product(product, params[:quantity].to_i)
    if @cart.save
      render json: @cart, status: :ok
    else
      render json: { errors: @cart.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def remove_item
    product = Product.find(params[:product_id])
    @cart.remove_product(product)
    if @cart.save
      render json: @cart, status: :ok
    else
      render json: { errors: @cart.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def checkout
    if @cart.checkout
      render json: { message: 'Order placed successfully' }, status: :ok
    else
      render json: { errors: @cart.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_cart
    @cart = current_user.orders.find_or_create_by(state: 'created')
  end
end
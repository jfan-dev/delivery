class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  before_validation :set_price

  validate :store_product

  private

  def set_price
    self.price = product.price if price.nil?
  end

  def store_product
    if product.store != order.store
      errors.add(:product, "should belong to `Store`: #{order.store.name}")
    end
  end
end

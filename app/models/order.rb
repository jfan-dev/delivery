class Order < ApplicationRecord
  belongs_to :buyer, class_name: "User", foreign_key: "buyer_id"
  belongs_to :store
  has_many :order_items
  has_many :products, through: :order_items

  validate :buyer_role

  state_machine initial: :created do
    event :accept do
      transition created: :accepted
    end
  end
  
  def add_product(product, amount = 1)
    order_item = order_items.find_or_initialize_by(product: product)
    order_item.amount ||= 0
    order_item.amount += amount
    order_item.price = product.price
    order_item.save
  end

  def remove_product(product)
    order_items.where(product: product).destroy_all
  end

  def checkout
    self.state = 'accepted'
    save
  end

  accepts_nested_attributes_for :order_items
  
  private

  def buyer_role
    errors.add(:buyer, "should be a `buyer`") unless buyer.buyer?
  end
end

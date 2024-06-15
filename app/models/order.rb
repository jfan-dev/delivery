class Order < ApplicationRecord
  belongs_to :buyer, class_name: "User"
  belongs_to :store
  has_many :order_items
  has_many :products, through: :order_items

  validate :buyer_role

  private

  def buyer_role
    errors.add(:buyer, "should be a `buyer`") unless buyer.buyer?
  end
end

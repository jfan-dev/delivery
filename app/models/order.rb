class Order < ApplicationRecord
  belongs_to :buyer, class_name: "User"
  belongs_to :store
  has_many :order_items
  has_many :products, through: :order_items

  validate :buyer_role

  def accept
    if self.state == :created
      update! state: :accepted
      
      # Send a Notification TODO
    else
      raise "Can't change to `:accepted` from #{self.state}"
    end
  end
  
  private

  def buyer_role
    errors.add(:buyer, "should be a `buyer`") unless buyer.buyer?
  end
end

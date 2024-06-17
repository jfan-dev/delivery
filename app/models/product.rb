class Product < ApplicationRecord
  belongs_to :store
  has_many :orders, through: :order_items

  validates :title, presence: true
  validates :price, numericality: { greater_than: 0 }
end

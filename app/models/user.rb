class User < ApplicationRecord
  enum role: { admin: 0, seller: 1, buyer: 2 }
  has_many :stores
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable
end
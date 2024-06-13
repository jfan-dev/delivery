class User < ApplicationRecord
  
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum role: { admin: 0, seller: 1, buyer: 2 }
  has_many :stores

  def self.token_for(user)
    payload = { id: user.id, email: user.email, role: user.role }
    JWT.encode payload, "muito.secreto", "HS256"
  end

  def self.from_token(token)
    payload = JWT.decode(token, "muito.secreto", true, { algorithm: 'HS256' }).first
    find_by(id: payload["id"])
  end
end
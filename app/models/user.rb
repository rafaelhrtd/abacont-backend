class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :jwt_authenticatable,
         :validatable, password_length: 8..128,
         jwt_revocation_strategy: Blacklist
  validates :email, presence: true, uniqueness: true
end

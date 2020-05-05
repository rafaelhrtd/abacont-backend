class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :jwt_authenticatable,
         :validatable, password_length: 8..128,
         jwt_revocation_strategy: Blacklist
  validates :email, presence: true, uniqueness: true
  validates :first_name, presence: true
  validates :last_name, presence: true

  before_validation :strip_whitespace
  
  belongs_to :company
  has_many :company_taggings, dependent: :delete_all
  has_many :companies, through: :company_taggings
  accepts_nested_attributes_for :company
  validates_associated :company

  # return role in given company (or nil if not part of company)
  def get_role(company)
    tag = self.company_taggings.where(company: company).first
    return tag.nil? ? nil : tag.role
  end
  private 

  def strip_whitespace
    self.first_name = self.first_name.strip unless self.first_name.nil?
    self.last_name = self.last_name.strip unless self.last_name.nil?
    self.email = self.email.strip unless self.email.nil?
  end

end

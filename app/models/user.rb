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
  attr_accessor :token
  validates_associated :company
  
  # switch roles given company

  def switch_company(company:)
    tag = CompanyTagging.where(user: self).where(company: company).first
    return nil if tag == nil
    self.update({
      company_id: tag.company_id,
      role: tag.role,
      can_read: tag.can_read,
      can_write: tag.can_write,
      can_edit: tag.can_edit,
      can_invite: tag.can_invite
    })
    return self
  end

  # returns true or false depending
  def check_privilege(company:, symbol:)
    tag = CompanyTagging.where(company: company, user: self).first
    return false if tag == nil 
    return tag[symbol]
  end

  private 

  def strip_whitespace
    self.first_name = self.first_name.strip unless self.first_name.nil?
    self.last_name = self.last_name.strip unless self.last_name.nil?
    self.email = self.email.strip unless self.email.nil?

    self.first_name = nil if self.first_name != nil && self.first_name.length == 0
    self.last_name = nil if self.last_name != nil && self.last_name.length == 0  
    self.email = nil if self.email != nil && self.email.length == 0  
  end

end

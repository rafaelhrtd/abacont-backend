class Company < ApplicationRecord
  has_many :company_taggings, dependent: :delete_all
  has_many :users, through: :company_taggings
  has_many :contacts
  has_many :projects
  has_many :transactions
  has_many :user_invites
  validates :name, presence: true

  before_validation :strip_whitespace
  # add a user with a given role to an existing company
  def add_user(user, role: nil)
    role ||= "reader"
    CompanyTagging.create(company: self, user: user, role: role)
  end

  # get clients
  def clients
    self.contacts.where(category: "client")
  end

  # get providers
  def providers
    self.contacts.where(category: "provider")
  end

  # remove a user from the company
  def remove_user(user)
    self.company_taggings.where(user: user).first.destroy
  end

  # turn over ownership from owner to given user
  def change_role(user, role: nil)
    role ||= "reader"
    if self.contains?(user) && role == "owner"
      self.company_taggings.where(user: self.owner).first.update(role: "leader")
      self.company_taggings.where(user: user).first.update(role: "owner")
    elsif self.contains?(user)
      self.company_taggings.where(user: user).first.update(role: role)
    end
  end

  # check if user is part of company
  def contains?(user)
    self.company_taggings.where(user: user).any?
  end

  # return company owner
  def owner
    self.company_taggings.where(role: "owner").first.user
  end

  # create employee invite

  def create_invite(params:, user:)
    params[:token] = SecureRandom.urlsafe_base64
    params[:company_id] = self.id
    params[:user_id] = user
    return UserInvite.create(params)
  end

  private 
  def strip_whitespace
    self.name = self.name.strip unless self.name.nil?

    self.name = nil if self.name != nil && self.name.length == 0
  end
end

class CompanyTagging < ApplicationRecord
  belongs_to :user
  belongs_to :company
  validate :unique_for_user
  validates :company_id, presence: true
  before_destroy :create_backup_company

  # if a user does not have his own company, create one
  def create_backup_company
    if self.user.companies.count - 1 <= 0
      company = Company.create(name: "Default Company")
      CompanyTagging.create(company: company,
        can_write: true,
        can_read: true,
        can_edit: true,
        can_invite: true,
        role: "owner",
        user: self.user)
      self.user.switch_company(company: company)
    end
  end

  def self.create_from_invite(invite:, user:)
    tag = CompanyTagging.create({
      company: invite.company,
      role: "employee",
      can_write: invite.can_write,
      can_read: invite.can_read,
      can_edit: invite.can_edit,
      can_invite: invite.can_invite,
      user: user})
    print tag.errors.first
    tag
  end

  def unique_for_user
    errors.add(:company_id, "already a member of this company.") if \
              CompanyTagging.where(user: self.user, company: self.company).\
              count > 0 && self.id.nil?
  end
end

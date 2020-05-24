class CompanyTagging < ApplicationRecord
  belongs_to :user
  belongs_to :company
  validate :unique_for_user

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

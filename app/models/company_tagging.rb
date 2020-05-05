class CompanyTagging < ApplicationRecord
  belongs_to :user
  belongs_to :company
  validate :unique_for_user

  # returns the possible roles one can have within a company
  def self.roles
    return ["reader", "writer", "leader", "owner"]
  end

  def unique_for_user
    errors.add(:company_id, "already a member of this company.") if \
              CompanyTagging.where(user: self.user, company: self.company).\
              count > 0 && self.id.nil?
  end
end

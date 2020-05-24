class UserInvite < ApplicationRecord
    belongs_to :user
    belongs_to :company
    validates :token, uniqueness: true
    validate :already_in_company
    validate :already_invited
    validates :email, presence: true
    

    private
    
    def already_in_company
        self.company.users.each do |user|
            if user.email == self.email 
                errors.add(:email, :already_in_company)
            end
        end
    end

    def already_invited
        self.company.user_invites.each do |invite|
            if invite.email == self.email
                errors.add(:email, :already_invited)
            end 
        end
    end
    
end

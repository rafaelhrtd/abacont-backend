class AddEmailToUserInvite < ActiveRecord::Migration[5.2]
  def change
    add_column :user_invites, :email, :string
  end
end

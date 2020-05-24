class AddPrivilegeToTaggings < ActiveRecord::Migration[5.2]
  def change

    add_column :company_taggings, :can_read, :boolean
    add_column :company_taggings, :can_write, :boolean
    add_column :company_taggings, :can_edit, :boolean
    add_column :company_taggings, :can_invite, :boolean

    add_column :user_invites, :can_read, :boolean
    add_column :user_invites, :can_write, :boolean
    add_column :user_invites, :can_edit, :boolean
    add_column :user_invites, :can_invite, :boolean

    add_column :users, :can_read, :boolean
    add_column :users, :can_write, :boolean
    add_column :users, :can_edit, :boolean
    add_column :users, :can_invite, :boolean

  end
end

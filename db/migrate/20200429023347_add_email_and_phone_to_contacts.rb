class AddEmailAndPhoneToContacts < ActiveRecord::Migration[5.2]
  def change
    add_column :contacts, :email, :string
    add_column :contacts, :phone, :string
  end
end

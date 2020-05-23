class CreateUserInvites < ActiveRecord::Migration[5.2]
  def change
    create_table :user_invites do |t|
      t.references :company, foreign_key: true
      t.references :user, foreign_key: true
      t.string :role
      t.string :token
      t.timestamps
    end
  end
end

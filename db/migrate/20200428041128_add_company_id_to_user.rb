class AddCompanyIdToUser < ActiveRecord::Migration[5.2]
  def change
    add_reference :users, :company, foreign_key: true, null: true
  end
end

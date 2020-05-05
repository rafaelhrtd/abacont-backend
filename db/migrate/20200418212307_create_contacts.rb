class CreateContacts < ActiveRecord::Migration[5.2]
  def change
    create_table :contacts do |t|
      t.string :name
      t.string :category
      t.references :company, foreign_key: true
      t.float :balance
      t.timestamps
    end
  end
end

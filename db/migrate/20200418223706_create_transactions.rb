class CreateTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :transactions do |t|
      t.references :project, foreign_key: true, null: true
      t.references :company, foreign_key: true
      t.references :contact, foreign_key: true, null: true
      t.references :transaction, :parent, index: true
      t.string :description
      t.string :contact_name
      t.string :project_name
      t.string :category
      t.string :bill_number
      t.date :date
      t.float :amount
      t.float :balance
      t.timestamps
    end
  end
end

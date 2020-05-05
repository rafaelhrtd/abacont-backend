class AddBillNumberToProject < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :bill_number, :string
  end
end

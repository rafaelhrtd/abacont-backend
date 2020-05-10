class AddPaymentInfoToTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :payment_type, :string 
    add_column :transactions, :cheque_number, :string
  end
end

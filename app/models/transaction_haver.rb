class TransactionHaver < ActiveRecord::Base

  has_many :transactions
  def revenues
    self.transactions.where(category: "revenue")
  end
  def payables
    self.transactions.where(category: "payable")
  end
  def receivables
    self.transactions.where(category: "receivable")
  end
  def expenses
    self.transactions.where(category: "expense")
  end
  def current_total
    total = 0
  end
end

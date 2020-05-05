module TransactionMethods
  extend ActiveSupport::Concern
  
  def revenues(month: nil, year: nil)
    self.transaction_by_category("revenue", month: month, year: year)
  end

  def expenses(month: nil, year: nil)
    self.transaction_by_category("expense", month: month, year: year)
  end

  def payables(month: nil, year: nil)
    self.transaction_by_category("payable", month: month, year: year)
  end

  def receivables(month: nil, year: nil)
    self.transaction_by_category("receivable", month: month, year: year)
  end

  def transaction_by_category(category, month: nil, year: nil)
    self.transactions.where(category: category)
  end

  def current_total
    total = self.total("revenue") - self.total("expense")
  end

  def total_revenues
    total("revenue")
  end

  def total_expenses
    total("expense")
  end

  def total(category)
    total = 0
    self.public_send(category.pluralize).each do |trans|
      total += trans.amount
    end
    total
  end
end

class Contact < ApplicationRecord
  has_many :addresses
  belongs_to :company
  validate :unique_for_company
  has_many :projects
  has_many :transactions
  validates :category, presence: true
  validates :name, presence: true
  validate :appropriate_category
  before_validation :strip_whitespace
  after_save :update_dependents

  before_create { |cont| cont.balance = 0 }

  def unique_for_company
    errors.add(:name, :taken) if \
              self.company.contacts.where(name: self.name).\
              count > 0 && self.id.nil?
  end

  def is_provider?
    self.category == "provider"
  end

  def is_client?
    self.category == "client"
  end

  def update_time
    self.touch(:updated_at)
  end

  # update contact name in dependents 
  def update_dependents
    if !self.previous_changes[:name].nil? || self.id_previously_changed?
      self.transactions.each do |tran|
        tran.update(contact_name: self.name)
      end
      self.projects.each do |proj|
        proj.update(contact_name: self.name)
      end
    end
  end

  def latest_transactions
    transactions = {}
    transactions[:expense] = self.transactions.where(category: "expense").order(date: :desc).first(5)
    transactions[:revenue] = self.transactions.where(category: "revenue").order(date: :desc).first(5)
    transactions[:payable] = self.transactions.where(category: "payable").order(date: :desc).first(5)
    transactions[:receivable] = self.transactions.where(category: "receivable").order(date: :desc).first(5)
    return transactions
  end

  def recalculate_balance
    total = 0
    if self.category == "client" 
      self.transactions.where(category: "receivable").each do |trans|
        total += trans.balance 
      end
      self.update(balance: total)
    else 
      self.transactions.where(category: "payable").each do |trans|
        total += trans.balance 
      end
      self.update(balance: total)
    end
  end

  private

  def appropriate_category
    if !["provider", "client"].include? self.category
      errors.add(:category, "is not acceptable")
    end
  end


  def strip_whitespace
    self.phone = self.phone.strip unless self.phone.nil?
    self.name = self.name.strip unless self.name.nil?
    self.email = self.email.strip unless self.email.nil?
  end

end

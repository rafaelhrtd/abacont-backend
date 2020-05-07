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

  def latest_transactions
    transactions = {}
    transactions[:expense] = self.transactions.where(category: "expense").order(date: :desc).first(5)
    transactions[:revenue] = self.transactions.where(category: "revenue").order(date: :desc).first(5)
    transactions[:payable] = self.transactions.where(category: "payable").order(date: :desc).first(5)
    transactions[:receivable] = self.transactions.where(category: "receivable").order(date: :desc).first(5)
    transactions.each do |key, collection|
      collection.each do |tran|
        tran.contact_name = tran.contact.name if !tran.contact.nil?
        tran.project_name = tran.project.name if !tran.project.nil?
      end
    end
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

  def self.get_search_results(user:, params:)
    contacts = Contact.where(company: user.company).where(category: params[:category])\
      .order(name: :asc)
    results = []
    contacts.each do |contact|
      results.push({id: contact.id, name: contact.name})
    end
    return results
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

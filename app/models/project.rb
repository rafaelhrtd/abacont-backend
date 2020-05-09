class Project < ApplicationRecord
  include TransactionMethods
  belongs_to :company
  belongs_to :contact, optional: true
  has_many :transactions
  validates :value, presence: true, numericality: {greater_than: 0}
  validates :name, presence: true
  validate :unique_for_company
  validate :must_be_client
  validate :non_existent_contact
  accepts_nested_attributes_for :contact
  validates_associated :contact
  after_save :update_dependents


  before_validation :strip_whitespace

  attr_accessor :contact_name

  def update_dependents
    if !self.previous_changes[:name].nil? || self.id_previously_changed?
      self.transactions.each do |tran|
        tran.update(contact_name: self.name)
      end
    end
  end

  # allows sending of virtual attributes as json
  def as_json(options = { })
    # just in case someone says as_json(nil) and bypasses
    # our default...
    super((options || { }).merge({
      :methods => [:contact_name]
    }))
  end

  # renders info for show
  def show 
    project = self
    project.contact_name = self.contact.name if !self.contact.nil?

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
    object = {
      project: project,
      transactions: transactions,
      summary: self.summary
    }
  end

  def self.get_search_results(user:, params:)
    projects = Project.where(company: user.company).order(name: :asc)
    results = []
    projects.each do |project|
      results.push({id: project.id, name: project.name})
    end
    return results
  end

  def summary 
    object = {revenues: {}, expenses: {}}
    object[:revenues][:billed] = (self.billed_to_receive)
    object[:revenues][:received] = (self.total_received)
    object[:expenses][:billed] = (self.billed_to_pay)
    object[:expenses][:paid] = (self.total_paid)
    object
  end

  # calculate total that has been billed to receive (not necessarily paid already)
  def billed_to_receive
    total = 0
    self.transactions.where(category: "receivable").each {|tran| total += tran.amount}
    self.standalone_revenues.each {|tran| total += tran.amount}
    total
  end

  # calculate total that has been billed to pay (not necessarily paid already)
  def billed_to_pay
    total = 0
    self.transactions.where(category: "payable").each {|tran| total += tran.amount}
    self.standalone_expenses.each {|tran| total += tran.amount}
    total
  end

  # calculate total amount of money paid
  def total_paid 
    total = 0
    self.transactions.where(category: "expense").each {|tran| total += tran.amount}
    total
  end 

  # calculate the total amount of money received.
  def total_received
    total = 0
    self.transactions.where(category: "revenue").each {|tran| total += tran.amount}
    total
  end

  def standalone_revenues
    self.transactions.where(category: "revenue").where(parent_id: nil)
  end

  def standalone_expenses
    self.transactions.where(category: "expense").where(parent_id: nil)
  end



  private
  def must_be_client
    if !self.contact.nil? && !self.contact.is_client?
      errors.add(:contact, :not_client)
    end
  end


  # if submitted contact does not exist
  def non_existent_contact
    print "\n\n\n#{self.contact_id}\n\n\n"
    if self.contact_id == 0
      errors.add(:contact_id, :non_existent_contact)
    end
  end


  def unique_for_company
    errors.add(:name, :taken) if \
              self.company.projects.where(name: self.name).\
              count > 0 && self.id.nil?
  end

  def strip_whitespace
    self.description = self.description.strip unless self.description.nil?
    self.name = self.name.strip unless self.name.nil?
    self.bill_number = self.bill_number.strip unless self.bill_number.nil?


    self.description = nil if self.description != nil && self.description.length == 0
    self.name = nil if self.name != nil && self.name.length == 0
    self.bill_number = nil if self.bill_number != nil && self.bill_number.length == 0  
  end
  
end

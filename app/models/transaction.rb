class Transaction < ApplicationRecord
  belongs_to :company
  belongs_to :project, optional: true
  belongs_to :contact, optional: true
  belongs_to :parent, class_name: "Transaction", optional: true
  has_many :children, class_name: "Transaction", foreign_key: "parent_id"
  validates :amount, presence: true, numericality: {greater_than: 0}
  validates :date, presence: true
  validate :can_have_parent
  validate :acceptable_category
  validate :excessive_payment
  validate :must_have_contact
  validate :appropriate_contact
  validate :non_existent_project
  validate :appropriate_parent
  validate :non_existent_contact
  validates :category, presence: true
  # set balance to zero before saving
  before_create { |trans| trans.balance = trans.amount }
  # change contact updated_at every time it is saved
  after_save :update_contact
  after_save :adjust_balance
  after_destroy :post_destroy_recalculate
  after_create :get_parent_names
  attr_accessor :contact_name, :project_name


  accepts_nested_attributes_for :contact
  validates_associated :contact

  accepts_nested_attributes_for :project
  validates_associated :project

  before_validation :strip_whitespace

  # list of acceptable transaction category
  def self.categories
    ["payable", "receivable", "expense", "revenue"]
  end

  # return children
  def children
    Transaction.where(parent_id: self.id)
  end

  # if payable or receivable
  def promised?
    return ["receivable", "payable"].include? self.category
  end

  # get name of contact and of project if applicable and update / recalculate
  def get_parent_names
    self.update(project_name: self.project.name) if !self.project.nil?
    self.update(contact_name: self.contact.name) if !self.contact.nil?
    self.contact.update_time if self.contact != nil
    self.contact.recalculate_balance if !self.contact.nil? && self.promised?
    self.parent.recalculate_balance if !self.parent.nil?
  end

  # update parents after destroy
  def post_destroy_recalculate
    self.contact.update_time if self.contact != nil
    self.contact.recalculate_balance if !self.contact.nil? && self.promised?
    self.parent.recalculate_balance if !self.parent.nil?
  end

  # update the updated_at column of parent contact
  def update_contact
    if self == nil || !self.previous_changes[:amount].nil?
      self.contact.update_time if self.contact != nil
    end
  end

  # get for index
  def self.get_by_params(params:, user:)
    transactions = user.company.transactions
    unless params[:xls] && params[:project_id] != nil
      if params[:yearly] == "true"
        transactions = Transaction.get_dates(year: params[:year], user: user)
        transactions.order(date: :desc)
      else 
        transactions = Transaction.get_dates(year: params[:year], month: (params[:month].to_i + 1), user: user)
        transactions.order(date: :desc)
      end
    end
    if params[:project_id] != nil 
      transactions = transactions.where(project_id: params[:project_id])
    end

    if params[:parent_id] != nil 
      transactions = transactions.where(parent_id: params[:parent_id])
    end

    if params[:contact_id] != nil 
      print "\n\n #{transactions.count} \n\n"
      transactions = transactions.where(contact_id: params[:contact_id])
      print "\n\n #{transactions.count} \n\n"
    end
    # if no page is provided
    if params[:page] == nil || params[:xlsx] == "true"
      if params[:xlsx] != "true"
        return_object = {
          revenue: transactions.where(category: "revenue").order(date: :desc, created_at: :desc).first(5),
          expense: transactions.where(category: "expense").order(date: :desc, created_at: :desc).first(5),
          payable: transactions.where(category: "payable").where("balance > ?", 5E-3).order(date: :desc, created_at: :desc).first(5),
          receivable: transactions.where(category: "receivable").where("balance > ?", 5E-3).order(date: :desc, created_at: :desc).first(5),
        }
      else 
        return_object = {
          revenue: transactions.where(category: "revenue").order(date: :desc, created_at: :desc),
          expense: transactions.where(category: "expense").order(date: :desc, created_at: :desc),
          payable: transactions.where(category: "payable").where("balance > ?", 5E-3).order(date: :desc, created_at: :desc),
          receivable: transactions.where(category: "receivable").where("balance > ?", 5E-3).order(date: :desc, created_at: :desc),
        }        
      end
      return_object.each do |key, value|
        value.each do |tran|
          tran.project_name = tran.project.name if tran.project != nil
          tran.contact_name = tran.contact.name if tran.contact != nil
        end
      end
      return { transactions: return_object, summary: Transaction.company_summary(user: user, params: params)}

    else
      per_page = 10
      first_index = (params[:page].to_i - 1) * per_page
      last_index = params[:page].to_i * per_page -1
      transactions = transactions.where(category: params[:category])
      if ["payable", "receivable"].includes(params[:category])
        transactions = transactions.where("balance > ?", 5E-3)
      end

      # get total number of pages
      pages = (transactions.count / 20.0).ceil()

      transactions = transactions.order(date: :desc, created_at: :desc)[first_index..last_index]
      transactions.each do |tran|
        tran.project_name = tran.project.name if tran.project != nil
        tran.contact_name = tran.contact.name if tran.contact != nil
      end
      return {transactions: transactions, total_pages: pages}
    end
  end

  # company summary
  def self.company_summary(user:, params:)
    if params[:yearly] == "true"
      transactions = Transaction.get_dates(year: params[:year], user: user)
      transactions.order(date: :desc)
    else 
      transactions = Transaction.get_dates(year: params[:year], month: (params[:month].to_i + 1), user: user)
      transactions.order(date: :desc)
    end
    summary = {
      revenue: Transaction.total_from_collection(transactions: transactions.where(category: "revenue")),
      expense: Transaction.total_from_collection(transactions: transactions.where(category: "expense")),
      receivable: Transaction.total_from_collection(transactions: transactions.where(category: "receivable")),
      payable: Transaction.total_from_collection(transactions: transactions.where(category: "payable"))
    }
  end
  
  # allows sending of virtual attributes as json
  def as_json(options = { })
    # just in case someone says as_json(nil) and bypasses
    # our default...
    super((options || { }).merge({
      :methods => [:project_name, :contact_name]
    }))
  end

  # get totals
  def self.total_from_collection(transactions:)
    total = 0
    if transactions.count > 0
      # calculate balance
      if ["receivable", "payable"].include? transactions.first.category
        transactions.each do |tran|
          total += tran.balance
        end
        return total
      # calculate amount
      else 
        transactions.each do |tran|
          total += tran.amount
        end
        return total        
      end
    else
      return total
    end
  end

  # recalculate balance of parent / contact
  def adjust_balance
    if self.promised? && !self.previous_changes[:amount].nil?
      self.recalculate_balance
    end
    if !self.previous_changes[:balance].nil? || !self.previous_changes[:amount].nil?
      if !self.contact.nil?
        self.contact.recalculate_balance
      end
      if !self.parent.nil?
        self.parent.recalculate_balance
      end
    end
  end

  # include contact as property
  def with_contact 
    transaction = self 
    transaction[:contact] = self.contact
    return transaction
  end

  def recalculate_balance
    balance = self.amount
    self.children.each do |child|
      balance -= child.amount 
    end
    balance = 0 if balance < 0
    self.update(balance: balance)
  end


  def destroy_with_params(params:, user:)
    if user.valid_password?(params[:password])
      if self.company_id != user.company_id
        return { error: "Esta transacción no pertenece a tu compañía." }
      end
      if params[:destroy_children] == "true"
        self.children.each {|tran| tran.destroy_with_params(params: params, user: user)}
      else 
        # remove project from transactions
        self.children.each {|tran| tran.update(parent_id: nil)}
      end
      self.destroy
      return {success: true}
    else
      return {error: "La contraseña ingresada no es la correcta."}
    end
  end
  



  private
  # checks if the category of transaction is included within the acceptable ones
  def acceptable_category
    errors.add(:unacceptable_category, "is not valid.") if !Transaction.categories.include? self.category
  end

  # receivables and payables are not allowed to have parents.
  def can_have_parent
    if self.parent != nil && self.promised?
      errors.add(:parent, :no_parent_allowed, message: "is now allowed for this kind of transaction.")
    end
  end

  # child cannot have a greater amount than parent's remainder
  def excessive_payment
    if !self.promised? && self.parent != nil
      balance = self.parent.amount
      Transaction.where(parent_id: self.parent_id).each do |pmt|
        balance -= pmt.amount
      end
      balance = balance.round(2) - self.amount
      if balance < -0.0001
        errors.add(:amount, :excessive_payment, message: "is greater than parent's remaining balance.")
      end
    end
  end

  # receivables and payables MUST be tied to a contact
  def must_have_contact
    if self.promised?
      errors.add(:contact, :need_contact) if self.contact.nil?
    end
  end

  # contact must be of one of two types
  def appropriate_contact
    if self.category == "receivable" && !self.contact.nil? && !self.contact.is_client?
      errors.add(:contact, "must be client.")
    elsif self.category == "payable" && !self.contact.nil? && !self.contact.is_provider?
      errors.add(:contact, "must be provider.")
    end
  end

  # only promises can be parents
  def appropriate_parent
    if !self.parent.nil?
      errors.add(:parent_id, :unacceptable_parent, message: "must be either a payable or a receivable") if \
              !self.parent.promised?
    end
  end

  # non-existent contact
  def non_existent_contact
    if self.contact_id == 0
      errors.add(:contact_id, :non_existent_contact)
    end
  end
  # non-existent contact
  def non_existent_project
    if self.project_id == 0
      errors.add(:project_id, :non_existent_project)
    end
  end


  def strip_whitespace
    self.description = self.description.strip unless self.description.nil?
    self.bill_number = self.bill_number.strip unless self.bill_number.nil?
    self.bill_number = nil if self.bill_number != nil && self.bill_number.length == 0
    self.description = nil if self.description != nil && self.description.length == 0    
  end

end

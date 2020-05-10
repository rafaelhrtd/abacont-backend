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

  # destroy given params 
  def destroy_with_params(params:, user:)
    if user.valid_password?(params[:password])
      if self.company_id != user.company_id
        return { error: "Este contacto no pertenece a tu compañía." }
      end
      if params[:destroy_children] == "true"

        self.projects.each {|project| project.destroy_with_params(params: params, user: user)}
        self.transactions.each {|tran| tran.destroy_with_params(params: params, user: user)}

      else 
        # get or create temporary contact
        company = self.company

        contact = Contact.create(
          company_id: company.id,
          name: "Contacto borrado #{DateTime.now.strftime("%d/%m/%Y")}",
          category: self.category)

        # remove contact from orphans where possible
        self.projects.each { |project| project.update(contact_id: nil)}
        self.transactions.where(category: "expense").each {|tran| tran.update(contact_id: nil, contact_name: nil)}
        self.transactions.where(category: "revenue").each {|tran| tran.update(contact_id: nil, contact_name: nil)}

        # give temporary contact to orphaned debts
        self.transactions.where(category: "payable").each {|tran| tran.update(contact_id: contact.id, contact_name: nil)}
        self.transactions.where(category: "receivable").each {|tran| tran.update(contact_id: contact.id, contact_name: nil)}

        contact.destroy if contact.transactions.count == 0
      end
      self.destroy
      return {success: true}
    else
      return {error: "La contraseña ingresada no es la correcta."}
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

    self.email = nil if self.email != nil && self.email.length == 0
    self.name = nil if self.name != nil && self.name.length == 0    
    self.phone = nil if self.phone != nil && self.phone.length == 0    
  end

end

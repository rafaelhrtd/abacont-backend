class Project < ApplicationRecord
  include TransactionMethods
  belongs_to :company
  belongs_to :contact, optional: true
  has_many :transactions
  validates :value, presence: true, numericality: {greater_than: 0}
  validates :name, presence: true
  validate :unique_for_company
  accepts_nested_attributes_for :contact
  validates_associated :contact
  after_save :update_dependents

  validate :must_be_client
  before_validation :strip_whitespace

  def update_dependents
    if !self.previous_changes[:name].nil? || self.id_previously_changed?
      self.transactions.each do |tran|
        tran.update(contact_name: self.name)
      end
    end
  end

  private
  def must_be_client
    if !self.contact.nil? && !self.contact.is_client?
      errors.add(:contact, :not_client)
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
  end
  
end

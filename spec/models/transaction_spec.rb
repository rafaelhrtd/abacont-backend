require 'rails_helper'

RSpec.describe Transaction, type: :model do
  let(:company) {Fabricate(:company)}

  context "basic validations" do
    before do
      @transaction = Transaction.create()
    end
    it "expect amount to be present" do
      expect(@transaction.errors[:amount].size).to eq(2)
    end
    it "expect amount to be positive" do
      @transaction.update(amount: -2)
      expect(@transaction.errors[:amount].size).to eq(1)
    end
    it "expect company to be present" do
      expect(@transaction.errors[:company].size).to eq(1)
    end
    it "expect category to be present" do
      expect(@transaction.errors[:category].size).to eq(2)
    end
    it "expects standard category" do
      @transaction.update(category: "lol")
      expect(@transaction.errors[:category].size).to eq(1)
    end
    it "accepts appropriate params" do
      @transaction.update(company: company, amount: 400, category: "expense")
      expect(@transaction.save).to be_truthy
    end
  end

  context "payable and receivable" do
    it "must have no parent" do
      @one = Transaction.create(amount: 100, company: company, \
                                contact: company.clients.first, category: "receivable")
      @two = Transaction.create(amount: 100, company: company, \
                                contact: company.clients.first, category: "receivable")
      @one.update(parent: @two)
      expect(@one.errors[:parent].size).to eq(1)
    end
    it "can list children" do
      @one = Transaction.create(amount: 100, company: company, \
                  category: "receivable", contact: company.clients.first)
      5.times do
        Transaction.create(amount: 20, parent: @one,\
                           company: company, category: "expense")
      end
      expect(@one.children.count).to eq(5)
    end
    it "can calculate remainder" do
      @one = Transaction.create(amount: 100, company: company, \
             category: "receivable", contact: company.clients.first)
      1.times do
        Transaction.create(amount: 15, parent: @one,\
                           company: company, category: "revenue")
      end
      expect((@one.balance - 85).abs < 0.0001).to be(true)
    end
    it "cannot children whose total is greater than its own" do
      @one = Transaction.create(amount: 100, company: company, category: "payable", \
             contact: company.providers.first)
      @two = Transaction.create(amount: 101, company: company,\
                                category: "expense", parent: @one)
      expect(@two.errors[:amount].count).to eq(1)
    end
    it "must belong to a contact" do
      @one = Transaction.create(amount: 100, company: company, category: "payable")
      expect(@one.errors[:contact].count).to eq(1)
    end
    it "must create a proper receivable and payable" do
      expect(\
        Transaction.create(amount: 100, category: "receivable", \
                    contact: company.clients.first, company: company).errors.count\
      ).to eq(0)
    end

  end

  context "payable" do
    it "must belong to a contact who is a provider" do
      @one = Transaction.create(amount: 100, company: company, \
             category: "payable", contact: company.clients.first)
      expect(@one.errors[:contact].count).to eq(1)
    end
  end

  context "receivable" do
    it "must belong to a contact who is a client" do
      @one = Transaction.create(amount: 100, company: company, \
             category: "receivable", contact: company.providers.first)
      expect(@one.errors[:contact].count).to eq(1)
    end
  end

  context "revenues and expenses" do
    it "must be able to show its parent when it has one" do
      @one = Transaction.create(amount: 100, company: company, category: "payable", \
             contact: company.providers.first)
      @two = Transaction.create(amount: 101, company: company,\
                                category: "expense", parent: @one)
      expect(@two.parent).to eq(@one)
    end
    it "cannot be a parent" do
      @one = Transaction.create(amount: 100, company: company, category: "expense", \
             contact: company.providers.first)
      @two = Transaction.create(amount: 101, company: company,\
                                category: "expense", parent: @one)
      expect(@two.errors[:parent].count).to eq(1)

    end
  end

end

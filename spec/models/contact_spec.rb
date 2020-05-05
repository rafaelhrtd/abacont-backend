require 'rails_helper'

RSpec.describe Contact, type: :model do
  let(:company) {Fabricate(:company)}

  context "adding clients" do
    it "fails when adding a client with the same name" do
      expect(Contact.create(company: company, name: company.contacts.first.name).\
             errors[:name].size).to eq(1)
    end
  end
end

require 'rails_helper'

RSpec.describe Company, type: :model do
  let(:company) { Fabricate(:company) }
  let(:user) { company.users.last }
  let(:owner) { company.users.first }
  let(:outside_user) {Fabricate(:user)}

  context "before making changes" do
    it "expects user to be part of company" do
      expect(company.contains? user).to be(true)
    end
    it "expects outside user NOT to be part of company" do
      expect(company.contains? outside_user).to be(false)
    end
    it "gets owner" do
      expect(company.owner).to eq(owner)
    end
    it "gets clients and providers" do
      expect(company.clients.count).to eq(4)
      expect(company.providers.count).to eq(2)
    end
  end

  context "adds new user" do
    before do
      company.add_user(outside_user, role: "leader")
    end
    it "adds new user" do
      expect(company.contains? outside_user).to be(true)
    end
    it "gives new user correct role" do
      expect(outside_user.role(company)).to eq("leader")
    end
  end

  context "adding existing user" do
    before do
      tag = CompanyTagging.create(company: company, user: owner)
    end
    it "has appropriate error" do
      expect(CompanyTagging.create(company: company, user: owner).\
             errors[:company_id].size).to eq(1)
    end
  end

  context "removing users" do
    before do
      company.remove_user(user)
    end
    it "removes user from company" do
      expect(user.companies.any?).to be(false)
    end
  end

  context "changing roles (not ownership)" do
    before do
      company.change_role(user, role: "reader")
    end
    it "changes roles properly" do
      expect(user.role(company)).to eq("reader")
    end
  end

  context "changing ownership" do
    before do
      company.change_role(user, role: "owner")
    end
    it "changes ownership properly" do
      expect(user.role(company)).to eq("owner")
      expect(owner.role(company)).to eq("leader")
    end
  end

end

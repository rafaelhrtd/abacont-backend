require 'rails_helper'

RSpec.describe Project, type: :model do
  let(:company) {Fabricate(:company)}
  it "must belong to a company" do
    @one = Project.create(value: 100, name: "Test 2")
    expect(@one.errors[:company].count).to eq(1)
  end
  it "must have a client if it has a contact" do
      @one = Project.create(value: 100, name: "Test 2", contact: company.providers.first)
      expect(@one.errors[:company].count).to eq(1)
  end
  it "must be able to calculate all expenses" do
    project = company.projects.first
    expect(((project.total_expenses) - 300).abs < 0.0001).to be(true)
  end
  it "must be able to calculate all revenues" do
    project = company.projects.first
    expect(((project.total_revenues) - 500).abs < 0.0001).to be(true)
  end
  it "must be able to list all of its transactions by category" do
    expect(company.projects.first.revenues.count).to eq(4)
    expect(company.projects.first.expenses.count).to eq(3)
    expect(company.projects.first.payables.count).to eq(2)
    expect(company.projects.first.receivables.count).to eq(1)
  end
  it "must be able to calculate its total expected value" do
    project = company.projects.first
    expect(((project.current_total) - 200).abs < 0.0001).to be(true)
  end
end

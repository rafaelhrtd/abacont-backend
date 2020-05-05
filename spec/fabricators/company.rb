Fabricator(:company) do
  name Faker::Name
  after_build do |company|
    Fabricate(:company_tagging, company: company, role: "owner")
    3.times {Fabricate(:company_tagging, company: company)}
    2.times {|i| Fabricate(:contact, company: company, \
                 name: "#{Faker::Name}#{i}", category: "provider")}
    4.times {|i| Fabricate(:contact, company: company, \
                 name: "#{Faker::Name}#{i + 2}", category: "client")}
    Fabricate(:project, company: company, value: 1000, contact: company.clients.first)
    3.times {Fabricate(:transaction, {
        amount: 100,
        project: company.projects.first,
        company: company,
        category: "expense",
        date: Time.now
      })}
    4.times {Fabricate(:transaction, {
        amount: 125,
        project: company.projects.first,
        company: company,
        category: "revenue",
        date: Time.now
      })}
    2.times {Fabricate(:transaction, {
        amount: 125,
        project: company.projects.first,
        company: company,
        category: "payable",
        contact: company.providers.first,
        date: Time.now
      })}
    1.times {Fabricate(:transaction, {
        amount: 125,
        project: company.projects.first,
        company: company,
        category: "receivable",
        contact: company.clients.first,
        date: Time.now
      })}
  end
end

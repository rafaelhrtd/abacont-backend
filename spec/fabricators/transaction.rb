Fabricator(:transaction) do
  company
  contact nil
  amount
  project nil
  description "A test description."
  category "expense"
end

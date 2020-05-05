Fabricator(:user) do
  email { |attrs| "#{Faker::Name.name.parameterize}@example.com" }
  first_name { "pepito" }
  last_name { "gonzález" }
  password { "123213123" }
  company
end

Fabricator(:user) do
  email { |attrs| "#{Faker::Name.name.parameterize}@example.com" }
  password { "123213123" }
end

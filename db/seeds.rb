# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

user = User.create(first_name: "Rafael", last_name: "Hurtado", email: "test@gmail.com", \
    password: "12312312", company_attributes: {name: "Test Company"}, role: "owner")
comp = user.company

2.times do |k|
    5.times do |i|
        contact = Contact.new
        contact.name = "Cliente #{i}" if k == 0
        contact.name = "Proveedor #{i}" if k == 1
        contact.phone = "204-200-3333"
        contact.email = "oll@gmail.com"
        contact.category = "client" if k == 0
        contact.category = "provider" if k == 1
        contact.company = comp
        contact.save
        100.times do |j|
            transaction = Transaction.new
            transaction.amount = rand() * 1000
            transaction.description = "A description"
            transaction.contact = contact
            transaction.category = k == 0 ? "receivable" : "payable"
            transaction.company = transaction.contact.company
            transaction.date = Time.now
            transaction.save
            transaction.date = rand(1.years).seconds.ago
            transaction.save
        end
        100.times do |j|
            transaction = Transaction.new
            transaction.amount = rand() * 1000
            transaction.description = "A description"
            transaction.contact = contact
            transaction.category = k == 0 ? "revenue" : "expense"
            transaction.company = transaction.contact.company
            transaction.date = Time.now
            transaction.save
            transaction.date = rand(1.years).seconds.ago
            transaction.save
        end
    end
end

class CreateAddresses < ActiveRecord::Migration[5.2]
  def change
    create_table :addresses do |t|
      t.string :line_one
      t.string :line_two
      t.string :zipcode
      t.string :city
      t.string :state
      t.string :country
      t.references :contact, foreign_key: true
      t.timestamps
      t.timestamps
    end
  end
end

class CreateBlacklists < ActiveRecord::Migration[5.2]
  def change
    create_table :blacklist do |t|
      t.string :jti, null: false
    end
    add_index :blacklist, :jti
  end
end

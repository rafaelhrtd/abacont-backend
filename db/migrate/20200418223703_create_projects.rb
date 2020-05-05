class CreateProjects < ActiveRecord::Migration[5.2]
  def change
    create_table :projects do |t|
      t.string :name
      t.string :description
      t.references :contact, foreign_key: true
      t.references :company, foreign_key: true
      t.string :contact_name
      t.float :value
      t.timestamps
      t.string :status
    end
  end
end

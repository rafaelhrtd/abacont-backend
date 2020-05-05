class CreateCompanyTaggings < ActiveRecord::Migration[5.2]
  def change
    create_table :company_taggings do |t|
      t.references :user, foreign_key: true
      t.references :company, foreign_key: true
      t.string :role
      t.timestamps
    end
  end
end

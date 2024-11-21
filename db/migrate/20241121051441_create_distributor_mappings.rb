class CreateDistributorMappings < ActiveRecord::Migration[7.1]
  def change
    create_table :distributor_mappings do |t|
      t.string :distributor_name
      t.integer :company_id
    end

    add_index :distributor_mappings, :distributor_name, unique: true
    add_foreign_key :distributor_mappings, :companies, column: :company_id
  end
end

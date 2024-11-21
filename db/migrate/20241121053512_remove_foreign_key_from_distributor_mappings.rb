class RemoveForeignKeyFromDistributorMappings < ActiveRecord::Migration[6.1]
  def change
    remove_foreign_key :distributor_mappings, :companies, column: :company_id
  end
end

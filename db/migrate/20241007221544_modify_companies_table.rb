class ModifyCompaniesTable < ActiveRecord::Migration[7.1]
  def change
    # Remove the auto-incrementing 'id' column
    remove_column :companies, :id

    # Set 'company_id' as the primary key
    execute "ALTER TABLE companies ADD PRIMARY KEY (company_id);"
  end
end

class AddIsTopCompanyToCompanies < ActiveRecord::Migration[7.1]
  def change
    add_column :companies, :is_top_company, :boolean
  end
end

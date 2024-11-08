class AddCompanyGroupToCompanies < ActiveRecord::Migration[7.1]
  def change
    add_column :companies, :company_group, :string
  end
end

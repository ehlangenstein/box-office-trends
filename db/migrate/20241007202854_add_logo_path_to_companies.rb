class AddLogoPathToCompanies < ActiveRecord::Migration[7.1]
  def change
    add_column :companies, :logo_path, :string
  end
end

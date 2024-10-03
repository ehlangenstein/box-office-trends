class CreateCompanies < ActiveRecord::Migration[7.1]
  def change
    create_table :companies do |t|
      t.integer "company_id" #unique ID from TMDB
      t.string "company_name" #from TMDB 

      t.timestamps
    end
  end
end

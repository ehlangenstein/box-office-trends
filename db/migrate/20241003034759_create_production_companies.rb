class CreateProductionCompanies < ActiveRecord::Migration[7.1]
  def change
    create_table :production_companies do |t|
      # one movie in movies can have multiple production companies
      t.integer "movie_id" #ref movie.tmdb_id
      t.integer "prodco_id" #ref company.company_id

      t.timestamps
    end
  end
end

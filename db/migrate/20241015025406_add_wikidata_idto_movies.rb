class AddWikidataIdtoMovies < ActiveRecord::Migration[7.1]
  def change
    add_column :movies, :wikidata_id, :integer
  end
end

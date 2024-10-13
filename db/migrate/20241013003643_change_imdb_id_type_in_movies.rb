class ChangeImdbIdTypeInMovies < ActiveRecord::Migration[7.1]
  def change
    change_column :movies, :imdb_id, :string
  end
end

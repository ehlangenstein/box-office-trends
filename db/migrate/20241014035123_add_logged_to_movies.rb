class AddLoggedToMovies < ActiveRecord::Migration[7.1]
  def change
    add_column :movies, :logged, :boolean
  end
end

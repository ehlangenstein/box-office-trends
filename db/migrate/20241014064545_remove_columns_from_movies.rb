class RemoveColumnsFromMovies < ActiveRecord::Migration[7.1]
  def change
    remove_column :movies, :open_startDate, :date
    remove_column :movies, :open_endDate, :date
    add_column :movies, :distributor, :string
    add_column :movies, :widest_release_theaters, :integer
  end
end

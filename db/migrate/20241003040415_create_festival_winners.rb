class CreateFestivalWinners < ActiveRecord::Migration[7.1]
  def change
    create_table :festival_winners do |t|
      t.integer "award_id" #from festival_awards.award_id
      t.integer "year"
      t.integer "winner" #id from TMDB

      t.timestamps
    end
  end
end

class CreateWeeklyBoxOffices < ActiveRecord::Migration[7.1]
  def change
    create_table :weekly_box_offices do |t|
      t.references :movie, foreign_key: true, index: true
      t.integer :week_number
      t.integer :year
      t.integer :rank
      t.integer :rank_last_week, default: 0
      t.integer :weekly_gross
      t.decimal :gross_change_per_week, precision: 5, scale: 2
      t.integer :total_theaters
      t.integer :change_theaters_per_week
      t.integer :per_theater_average_gross
      t.integer :total_gross
      t.integer :weeks_in_release
      t.string :distributor
    end
  end
end

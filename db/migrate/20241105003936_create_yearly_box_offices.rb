class CreateYearlyBoxOffices < ActiveRecord::Migration[7.1]
  def change
    create_table :yearly_box_offices do |t|
      t.references :movie, foreign_key: true, index: true
      t.integer :year
      t.integer :rank
      t.integer :domestic_gross
      t.integer :total_theaters
      t.integer :opening_rev
      t.decimal :percent_of_total, precision: 5, scale: 2
      t.integer :open_wknd_theaters
      t.date :opening_weekend
      t.string :distributor

    end
  end
end

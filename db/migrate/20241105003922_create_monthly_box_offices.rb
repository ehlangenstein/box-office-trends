class CreateMonthlyBoxOffices < ActiveRecord::Migration[7.1]
  def change
    create_table :monthly_box_offices do |t|
      t.references :movie, foreign_key: true, index: true
      t.integer :month
      t.integer :year
      t.integer :rank
      t.integer :domestic_gross
      t.integer :total_theaters
      t.integer :total_gross
      t.date :release_date
      t.string :distributor
    end
  end
end

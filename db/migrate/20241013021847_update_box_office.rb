class UpdateBoxOffice < ActiveRecord::Migration[7.1]
  def change
    create_table :box_offices do |t|
      t.integer :imdb_id, null: false
      t.integer :domestic_box_office
      t.integer :international_box_office
      t.integer :total_box_office
      t.integer :opening_weekend_box_office
      t.integer :theaters_count
      t.timestamps
    end
  end
end

class CreateBoxOffices < ActiveRecord::Migration[7.1]
  def change
    create_table :box_offices do |t|
      t.string :movie_title
      t.integer :revenue
      t.timestamps
    end
  end
end

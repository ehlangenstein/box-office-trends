class CreateFestivals < ActiveRecord::Migration[7.1]
  def change
    create_table :festivals do |t|
      #list of film festivals
      t.string "festival_name"
      t.integer "festival_id" # auto increment?


      t.timestamps
    end
  end
end

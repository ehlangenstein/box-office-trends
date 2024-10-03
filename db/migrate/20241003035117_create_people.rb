class CreatePeople < ActiveRecord::Migration[7.1]
  def change
    create_table :people do |t|
      t.integer "person_id" #from tmdb 
      t.string "name" #from tmdb
      t.string "role" 

      t.timestamps
    end
  end
end

class DropTableBoxOffices < ActiveRecord::Migration[7.1]
  def change
    drop_table :box_offices
  end
end

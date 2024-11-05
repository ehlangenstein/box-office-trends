class DropBoxOfficeTables < ActiveRecord::Migration[7.1]
  def change
    # Drop both tables
    drop_table :box_office, if_exists: true
    drop_table :box_offices, if_exists: true
  end
end

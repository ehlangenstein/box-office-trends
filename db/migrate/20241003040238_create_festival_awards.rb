class CreateFestivalAwards < ActiveRecord::Migration[7.1]
  def change
    create_table :festival_awards do |t|
      t.integer "festival_id" # from festival.festival_id
      t.string "award" # name of award
      t.integer "award_id" # index of awards for references

      t.timestamps
    end
  end
end

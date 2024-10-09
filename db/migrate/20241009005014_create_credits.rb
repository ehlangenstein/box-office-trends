class CreateCredits < ActiveRecord::Migration[7.1]
  def change
    create_table :credits do |t|
      t.references :movie, null: false, foreign_key: true
      t.references :person, null: false, foreign_key: true
      t.string "department"
      t.string "character"
      t.string "role"
      t.string "credit_id"
      t.timestamps
    end
  end
end

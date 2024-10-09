class ModifyPeopleTable < ActiveRecord::Migration[7.1]
  def change
    remove_column :people, :role, :string
    add_column :people, :profile_path, :string
  end
end

class AddCompanyIdToBoxOffices < ActiveRecord::Migration[7.1]
  def change
    add_reference :monthly_box_offices, :company, foreign_key: true
    add_reference :weekly_box_offices, :company, foreign_key: true
    add_reference :yearly_box_offices, :company, foreign_key: true
  end
end

class AddDepartmentIdToPrimaryPis < ActiveRecord::Migration[5.1]
  def change
    remove_column :primary_pis, :department, :string
    add_reference :primary_pis, :department, foreign_key: true, after: :email
  end
end

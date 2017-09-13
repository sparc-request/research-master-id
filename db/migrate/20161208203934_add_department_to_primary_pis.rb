class AddDepartmentToPrimaryPis < ActiveRecord::Migration[4.2]
  def change
    add_column :primary_pis, :department, :string, after: :name
  end
end

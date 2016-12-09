class AddDepartmentToPrimaryPis < ActiveRecord::Migration
  def change
    add_column :primary_pis, :department, :string, after: :name
  end
end

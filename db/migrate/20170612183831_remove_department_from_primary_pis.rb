class RemoveDepartmentFromPrimaryPis < ActiveRecord::Migration[5.1]
  def change
    remove_column :primary_pis, :department
    add_reference :primary_pis, :department, foreign_key: true, after: :protocol_id
  end
end

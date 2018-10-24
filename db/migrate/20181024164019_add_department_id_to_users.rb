class AddDepartmentIdToUsers < ActiveRecord::Migration[5.1]
  def change
    add_reference :users, :department, foreign_key: true, after: :name
  end
end

class AddNameToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :name, :string, after: :email
  end
end

class AddNetIdToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :net_id, :string, after: :email
  end
end

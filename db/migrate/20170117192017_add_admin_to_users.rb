class AddAdminToUsers < ActiveRecord::Migration
  def change
    add_column :users, :admin, :boolean, after: :email, default: false
  end
end

class AddDeveloperToUsers < ActiveRecord::Migration
  def change
    add_column :users, :developer, :boolean, after: :admin
  end
end

class AddDeveloperToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :developer, :boolean, after: :admin
  end
end

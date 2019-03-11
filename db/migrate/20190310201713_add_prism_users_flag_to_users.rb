class AddPrismUsersFlagToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :current_prism_user, :boolean, after: :developer
  end
end

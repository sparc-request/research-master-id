class FixPrismColumnNameToInterfolio < ActiveRecord::Migration[5.2]
  def change
    rename_column :users, :current_prism_user, :current_interfolio_user
  end
end

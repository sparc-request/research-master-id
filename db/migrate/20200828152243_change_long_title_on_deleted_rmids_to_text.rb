class ChangeLongTitleOnDeletedRmidsToText < ActiveRecord::Migration[5.2]
  def change
    change_column_default :deleted_rmids, :long_title, nil
    change_column :deleted_rmids, :long_title, :text
  end
end

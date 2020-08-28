class ChangeLongTitleOnDeletedRmidsToText < ActiveRecord::Migration[5.2]
  def change
    change_column :deleted_rmids, :long_title, :text
  end
end

class RenameColumnOnResearchMasters < ActiveRecord::Migration[5.1]
  def change
    rename_column :research_masters, :user_id, :creator_id
  end
end

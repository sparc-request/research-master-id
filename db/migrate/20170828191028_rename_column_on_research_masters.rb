class RenameColumnOnResearchMasters < ActiveRecord::Migration[5.1]
  def change
    remove_reference :research_masters, :user, index: true, foreign_key: true
    add_reference :research_masters, :creator, foreign_key: { to_table: :users }, after: :creator_id, type: :integer
  end
end

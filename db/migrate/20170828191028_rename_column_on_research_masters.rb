class RenameColumnOnResearchMasters < ActiveRecord::Migration[5.1]
  def change
    add_reference :research_masters, :creator, foreign_key: { to_table: :users }, after: :funding_source, type: :integer
  end
end

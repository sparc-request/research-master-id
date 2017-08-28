class AddPiIdToResearchMasters < ActiveRecord::Migration[5.1]
  def change
    add_reference :research_masters, :pi, foreign_key: { to_table: :users }, after: :creator_id, type: :integer
  end
end

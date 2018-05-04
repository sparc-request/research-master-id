class RemovePiNameFromResearchMasters < ActiveRecord::Migration[5.1]
  def change
    remove_column :research_masters, :pi_name
  end
end

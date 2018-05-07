class RemovePiNameFromResearchMasters < ActiveRecord::Migration[5.1]
  def up
    remove_column :research_masters, :pi_name
  end

  def down
    add_column :research_masters, :pi_name, :string
  end
end

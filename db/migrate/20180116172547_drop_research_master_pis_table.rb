class DropResearchMasterPisTable < ActiveRecord::Migration[5.1]
  def change
    drop_table :research_master_pis
  end
end

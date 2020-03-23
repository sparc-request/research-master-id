class AddCayuseRelations < ActiveRecord::Migration[5.2]
  def change
    create_join_table :research_masters, :protocols, table_name: "research_master_cayuse_relations" do |t|
      t.index :research_master_id
      t.index :protocol_id
      t.timestamps
    end
  end
end

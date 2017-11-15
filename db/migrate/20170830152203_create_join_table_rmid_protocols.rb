class CreateJoinTableRmidProtocols < ActiveRecord::Migration[5.1]
  def change
    create_join_table :research_masters, :protocols, table_name: "research_master_coeus_relations" do |t|
      t.index :research_master_id
      t.index :protocol_id
      t.timestamps
    end
  end
end

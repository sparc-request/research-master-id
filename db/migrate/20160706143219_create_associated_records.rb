class CreateAssociatedRecords < ActiveRecord::Migration
  def change
    create_table :associated_records do |t|
      t.references :research_master, index: true, foreign_key: true
      t.integer :sparc_id
      t.integer :coeus_id
      t.integer :eirb_id

      t.timestamps null: false
    end
  end
end

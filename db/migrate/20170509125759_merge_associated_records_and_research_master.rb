class MergeAssociatedRecordsAndResearchMaster < ActiveRecord::Migration
  def change
    add_column :research_masters, :sparc_id, :integer, after: :user_id
    add_column :research_masters, :eirb_id, :string, after: :sparc_id
    drop_table :associated_records
  end
end

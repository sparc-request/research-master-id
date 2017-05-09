class MergeAssociatedRecordsAndResearchMaster < ActiveRecord::Migration
  def change
    add_column :research_masters, :sparc_id, :integer, after: :user_id
    add_column :research_masters, :eirb_id, :integer, after: :sparc_id
    ResearchMaster.transaction do
      AssociatedRecord.all.each do |ar|
        ar.research_master.update(sparc_id: ar.sparc_id, eirb_id: ar.eirb_id)
      end
      drop_table :associated_records
    end
  end
end

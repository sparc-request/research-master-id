class AddOriginalAssociationDatesToResearchMasters < ActiveRecord::Migration[5.2]
  def change
    add_column :research_masters, :eirb_original_association_date, :datetime, after: :eirb_association_date
    add_column :research_masters, :sparc_original_association_date, :datetime, after: :sparc_association_date

    research_masters = ResearchMaster.all
    
    research_masters.each do |research_master|
      if research_master.eirb_association_date.present?
        research_master.assign_attributes(eirb_original_association_date: research_master.eirb_association_date)
      end

      if research_master.sparc_association_date.present?
        research_master.assign_attributes(sparc_original_association_date: research_master.sparc_association_date)
      end

      research_master.save
    end
  end
end

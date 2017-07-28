task migrate_ar_data: :environment do
  AssociatedRecord.all.each do |ar|
    rm = ResearchMaster.find(ar.research_master_id)
    unless ar.sparc_id.nil?
      rm.update_attributes(
        sparc_protocol_id: ar.sparc_id,
        sparc_association_date: ar.created_at
      )
    end
    unless ar.eirb_id.nil?
      rm.update_attributes(
        eirb_protocol_id: ar.eirb_id,
        eirb_association_date: ar.created_at
      )
    end
  end
end

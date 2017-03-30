task migrate_to_sparc_pro_number: :environment do
  protocols = Protocol.where(type: 'SPARC').where.not(eirb_id: nil)

  protocols.each do |protocol|
    protocol.update_attribute(:sparc_pro_number, protocol.eirb_id)
    protocol.update_attribute(:eirb_id, nil)
  end
end

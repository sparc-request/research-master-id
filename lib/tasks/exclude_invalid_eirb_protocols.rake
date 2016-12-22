task exclude_invalid_eirb_protocols: :environment do
  protocols = Protocol.where(type: 'EIRB')

  protocols.each do |protocol|
    unless protocol.eirb_id.nil?
      if protocol.eirb_id.include?('MS') || protocol.eirb_id.include?('Original')
        protocol.destroy
      end
    end
  end
end


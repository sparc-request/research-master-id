task update_pi_name: :environment do

  sparc_api = ENV.fetch("SPARC_API")
  protocols = HTTParty.get("#{sparc_api}/protocols", timeout: 500, headers: {'Content-Type' => 'application/json'})

  protocols.each do |protocol|
    if Protocol.exists?(sparc_id: protocol['id'])
      record_to_update = Protocol.find_by(sparc_id: protocol['id'])
      unless record_to_update.primary_pi.nil?
        record_to_update.primary_pi.update_attribute(:last_name, protocol['last_name'])
        record_to_update.primary_pi.update_attribute(:first_name, protocol['first_name'])
      end
    end
  end
end

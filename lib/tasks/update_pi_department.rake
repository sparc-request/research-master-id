task update_pi_department: :environment do
  sparc_api = ENV.fetch('SPARC_API')

  protocols = HTTParty.get(
    "#{sparc_api}/protocols",
    timeout: 500,
    headers: { 'Content-Type' => 'application/json' }
  )

  protocols.each do |protocol|
    protocol_to_update = Protocol.find_by(sparc_id: protocol['id'])
    pi = protocol_to_update.primary_pi
    pi.update_attribute(:department, protocol['pi_department'])
  end
end

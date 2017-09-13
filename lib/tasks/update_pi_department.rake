task update_pi_department: :environment do
  eirb_api = ENV.fetch('EIRB_API')
  eirb_api_token = ENV.fetch('EIRB_API_TOKEN')
  sparc_api = ENV.fetch('SPARC_API')

  protocols = HTTParty.get(
    "#{sparc_api}/protocols",
    timeout: 500,
    headers: { 'Content-Type' => 'application/json' }
  )
  eirb_studies = HTTParty.get("#{eirb_api}/studies.json?musc_studies=true",
                              timeout: 500, headers: {'Content-Type' => 'application/json',
                                                      "Authorization" => "Token token=\"#{eirb_api_token}\""})

  protocols.each do |protocol|
    if Protocol.exists?(sparc_id: protocol['id'])
      protocol_to_update = Protocol.find_by(sparc_id: protocol['id'])
      pi = protocol_to_update.primary_pi
      unless pi.nil?
        if protocol['pi_department'].nil?
          pi.update_attribute(:department, Department.find_or_create_by(name: 'N/A'))
        else
          pi.update_attribute(:department, Department.find_or_create_by(name: protocol['pi_department']))
        end
      end
    end
  end

  eirb_studies.each do |study|
    if Protocol.exists?(eirb_id: study['pro_number'])
      study_to_update = Protocol.find_by(eirb_id: study['pro_number'])
      pi = study_to_update.primary_pi
      unless pi.nil?
        if study['pi_department'].nil?
          pi.update_attribute(:department, Department.find_or_create_by(name: 'N/A'))
        else
          pi.update_attribute(:department, Department.find_or_create_by(name: study['pi_department']))
        end
      end
    end
  end
end

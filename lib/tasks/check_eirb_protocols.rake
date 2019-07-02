task check_eirb_protocols: :environment do

  def find_protocol(pro_number, eirb_studies)
    eirb_studies.each do |study|
      if study['pro_number'] == pro_number
        return study
      end
    end
  end

  eirb_api        = ENV.fetch("EIRB_API")
  sparc_api        = ENV.fetch("SPARC_API")

  eirb_api_token  = ENV.fetch("EIRB_API_TOKEN")
  sparc_protocols = HTTParty.get("#{sparc_api}/protocols", timeout: 500, headers: {'Content-Type' => 'application/json'})
  eirb_studies = HTTParty.get("#{eirb_api}/studies.json?musc_studies=true", timeout: 500, headers: {'Content-Type' => 'application/json', "Authorization" => "Token token=\"#{eirb_api_token}\""})

  null_eirb_pi_studies  = Protocol.where(type: 'EIRB').where(primary_pi_id: nil)

  deleted_protocols = CSV.open("tmp/deleted_protocols.csv", "wb")
  deleted_protocols << ['ID', 'Type', 'Long Title', 'Eirb ID']

  # pro_numbers = eirb_studies.map{ |study| study['pro_number'] }
  pro_numbers = []
  eirb_studies.each do |study|
    pro_numbers << study['pro_number']
  end

  null_eirb_pi_studies.each do |study|
    research_master = ResearchMaster.find_by_eirb_protocol_id(study.id)

    if pro_numbers.include?(study.eirb_id) && (research_master != nil)
      protocol = find_protocol(study.eirb_id, eirb_studies)
      pi = User.find_by_email(protocol['pi_email'])
      unless pi == nil
        study.update_attributes(primary_pi_id: pi.id)
      end
    else
      deleted_protocols << [study.id, study.type, study.long_title, study.eirb_id]
      study.destroy
    end
  end
end
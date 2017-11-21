require 'dotenv/tasks'

task import_data: :environment do

  sparc_api = ENV.fetch("SPARC_API")
  eirb_api =  ENV.fetch("EIRB_API")
  eirb_api_token = ENV.fetch("EIRB_API_TOKEN")
  protocols = HTTParty.get("#{sparc_api}/protocols", headers: {'Content-Type' => 'application/json'})
  eirb_studies = HTTParty.get("#{eirb_api}/studies.json?musc_studies=true",
                              timeout: 500, headers: {'Content-Type' => 'application/json',
                              "Authorization" => "Token token=\"#{eirb_api_token}\""})
  protocols.each do |protocol|
    sparc_protocol = Protocol.create(type: protocol['type'],
                               long_title: protocol['title'],
                               sparc_id: protocol['id'],
                               eirb_id: protocol['pro_number']
                              )
    unless protocol['pi_name'].nil?
      PrimaryPi.create(name: protocol['pi_name'], department: protocol['pi_department'].humanize.titleize,
                       protocol: sparc_protocol)
    end
  end
  eirb_studies.each do |study|
    eirb_study = Protocol.create(type: study['type'],
                            long_title: study['title'],
                            eirb_id: study['pro_number'],
                            eirb_institution_id: study['institution_id'],
                            eirb_state: study['state']
                           )
    eirb_study.save

    unless study['pi_name'].nil?
      PrimaryPi.create(name: study['pi_name'], protocol: eirb_study)
    end
  end
end

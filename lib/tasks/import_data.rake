task import_data: :environment do

  protocols = HTTParty.get('http://sparc_api/protocols', headers: {'Content-Type' => 'application/json'})
  eirb_studies = HTTParty.get('http://eirb_api/studies.json?musc_studies=true', headers: {'Content-Type' => 'application/json'})

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
    unless study['pi_name'].nil?
      PrimaryPi.create(name: study['pi_name'], protocol: eirb_study)
    end
  end
end

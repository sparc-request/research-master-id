task import_data: :environment do

  get_protocols = HTTParty.get('http://localhost:3000/protocols')
  protocols_array = JSON.parse(get_protocols.body)
  get_eirb_studies = HTTParty.get('https://api-eirb.musc.edu/studies.json')
  eirb_studies_array = JSON.parse(get_eirb_studies.body)

  protocols_hash = Hash[protocols_array.each_slice(2).to_a]

  eirb_hash = Hash[eirb_studies_array.each_slice(2).to_a]

  protocols = protocols_hash.merge(eirb_hash)

  protocols.each do |key, value|
    if key['type'] == 'SPARC'
      protocol = Protocol.create(type: key['type'],
                                 long_title: key['title'],
                                 sparc_id: key['id'])
      PrimaryPi.create(name: key['pi_name'],
                       protocol: protocol)
    elsif key['type'] == 'EIRB'
      protocol = Protocol.create(type: key['type'],
                                 long_title: key['title'],
                                 eirb_id: key['pro_number'])
      PrimaryPi.create(name: key['pi_name'],
                       protocol: protocol)
    end
  end
end

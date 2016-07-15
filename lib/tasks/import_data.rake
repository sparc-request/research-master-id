task import_data: :environment do

  get_protocols = HTTParty.get('http://localhost:3000/protocols')
  protocols_array = JSON.parse(get_protocols.body)
  get_eirb_studies = HTTParty.get('http://localhost:5000/studies.json')
  eirb_studies_array = JSON.parse(get_eirb_studies.body)

  protocols_hash = Hash[protocols_array.each_slice(2).to_a]

  eirb_hash = Hash[eirb_studies_array.each_slice(2).to_a]

  protocols = protocols_hash.merge(eirb_hash)

  protocols.each do |key, value|
    protocol = Protocol.create(type: key['type'],
                    pi_name: key['pi_name'],
                    department: key['department'],
                    long_title: key['title'],
                    short_title: key['short_title'])
    PrimaryPi.create(name: key['pi_name'], department: key['department'],
                     protocol: protocol)
  end


end

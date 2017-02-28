require 'dotenv/tasks'

task update_data: :environment do

  sparc_api = ENV.fetch("SPARC_API")
  eirb_api =  ENV.fetch("EIRB_API")
  protocols = HTTParty.get("#{sparc_api}/protocols", headers: {'Content-Type' => 'application/json'})
  eirb_studies = HTTParty.get("#{eirb_api}/studies.json?musc_studies=true", headers: {'Content-Type' => 'application/json'})

  protocols.each do |protocol|
    unless Protocol.exists?(sparc_id: protocol['id'])
      sparc_protocol = Protocol.create(type: protocol['type'],
                                       long_title: protocol['title'],
                                       sparc_id: protocol['id'],
                                       eirb_id: protocol['pro_number']
                                      )
      unless protocol['pi_name'].nil?
        PrimaryPi.find_or_create_by(name: protocol['pi_name'],
                                    department: protocol['pi_department'].humanize.titleize,
                                    protocol: sparc_protocol)
      end
    end
    unless protocol['research_master_id'].nil?
      if ResearchMaster.exists?(protocol['research_master_id'])
        ar = AssociatedRecord.find_or_create_by(
          research_master_id: protocol['research_master_id']
        )
        ar.update_attribute(:sparc_id, Protocol.find_by(sparc_id: protocol['id']).id)
      end
    end
  end
  eirb_studies.each do |study|
    unless Protocol.exists?(eirb_id: study['pro_number'])
      eirb_study = Protocol.create(type: study['type'],
                                   long_title: study['title'],
                                   eirb_id: study['pro_number'],
                                   eirb_institution_id: study['institution_id'],
                                   eirb_state: study['state']
                                  )
      unless study['pi_name'].nil?
        PrimaryPi.find_or_create_by(name: study['pi_name'], protocol: eirb_study)
      end
    end
    unless study['research_master_id'].nil?
      if ResearchMaster.exists?(study['research_master_id'])
        ar = AssociatedRecord.find_or_create_by(
          research_master_id: study['research_master_id']
        )
        ar.update_attribute(:eirb_id, Protocol.find_by(eirb_id: study['pro_number']).id)
      end
    end
  end
end

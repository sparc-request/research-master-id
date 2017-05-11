require 'dotenv/tasks'

task update_data: :environment do
  def create_and_filter_eirb_study(study)
    eirb_study = Protocol.create(type: study['type'],
                                 short_title: study['short_title'],
                                 long_title: study['title'],
                                 eirb_id: study['pro_number'],
                                 eirb_institution_id: study['institution_id'],
                                 eirb_state: study['state']
                                )
    eirb_study.long_title.gsub!(/[^a-zA-Z0-9\-.\s%\/$*<>!@#^\[\]{};:"'?&()-_=+]/, ' ')
    eirb_study.short_title.gsub!(/[^a-zA-Z0-9\-.\s%\/$*<>!@#^\[\]{};:"'?&()-_=+]/, ' ')
    eirb_study.save
 
    eirb_study
  end

  sparc_api = ENV.fetch("SPARC_API")
  eirb_api =  ENV.fetch("EIRB_API")
  eirb_api_token = ENV.fetch("EIRB_API_TOKEN")
  protocols = HTTParty.get("#{sparc_api}/protocols", timeout: 500, headers: {'Content-Type' => 'application/json'})
  eirb_studies = HTTParty.get("#{eirb_api}/studies.json?musc_studies=true",
                              timeout: 500, headers: {'Content-Type' => 'application/json',
                              "Authorization" => "Token token=\"#{eirb_api_token}\""})
  protocols.each do |protocol|
    unless Protocol.exists?(sparc_id: protocol['id'])
      sparc_protocol = Protocol.create(type: protocol['type'],
                                       short_title: protocol['short_title'],
                                       long_title: protocol['title'], 
                                       sparc_id: protocol['id'],
                                       sparc_pro_number: protocol['pro_number']
                                      )
      unless protocol['pi_name'].nil?
        PrimaryPi.find_or_create_by(name: protocol['pi_name'],
                                    department: protocol['pi_department'].humanize.titleize,
                                    protocol: sparc_protocol)
      end
    else
      existing_protocol = Protocol.find_by(sparc_id: protocol['id'])
      existing_protocol.update_attribute(:short_title, protocol['short_title'])
    end
    unless protocol['research_master_id'].nil?
      rm = ResearchMaster.find_by(id: protocol['research_master_id'])
      unless rm.nil?
        rm.update_attribute(:sparc_protocol_id, Protocol.find_by(sparc_id: protocol['id']).id)
      end
    end
  end
  eirb_studies.each do |study|
    if Protocol.exists?(eirb_id: study['pro_number'])
      protocol = Protocol.find_by(eirb_id: study['pro_number'])
      protocol.update_attribute(:short_title, study['short_title'])
    elsif Protocol.exists?(eirb_id: study['pro_number'])
      if Protocol.find_by(eirb_id: study['pro_number']).type == 'SPARC'
        eirb_study = create_and_filter_eirb_study(study)
      end
      unless study['pi_name'].nil?
        PrimaryPi.find_or_create_by(name: study['pi_name'], protocol: eirb_study)
      end
    else
      eirb_study = create_and_filter_eirb_study(study)
      unless study['pi_name'].nil?
        PrimaryPi.find_or_create_by(name: study['pi_name'], protocol: eirb_study)
      end
    end
    unless study['research_master_id'].nil?
      validated_states = ['Acknowledged', 'Approved', 'Completed', 'Disapproved', 'Exempt Approved', 'Expired',  'Expired - Continuation in Progress', 'External IRB Review Archive', 'Not Human Subjects Research', 'Suspended', 'Terminated', 'Withdrawn']
      rm = ResearchMaster.find_by(id: study['research_master_id'])
      unless rm.nil?
        if Protocol.where(eirb_id: study['pro_number'], type: 'EIRB').present?
          rm.update_attribute(:eirb_protocol_id, Protocol.where(eirb_id: study['pro_number'], type: 'EIRB').first.id)
        end
        if validated_states.include?(study['state'])
          rm.update_attributes(short_title: study['short_title'], long_title: study['title'], eirb_validated: true)
        end
      end
    end
  end
end

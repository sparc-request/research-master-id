require 'dotenv/tasks'

task update_research_master: :environment do
  sparc_api = ENV.fetch("SPARC_API")
  eirb_api =  ENV.fetch("EIRB_API")
  eirb_api_token = ENV.fetch("EIRB_API_TOKEN")
  protocols = HTTParty.get("#{sparc_api}/protocols", timeout: 500, headers: {'Content-Type' => 'application/json'})
  # eirb_studies = HTTParty.get("#{eirb_api}/studies.json?musc_studies=true",
  #                             timeout: 500, headers: {'Content-Type' => 'application/json',
  #                             "Authorization" => "Token token=\"#{eirb_api_token}\""})

  protocols.each do |protocol|
    unless protocol['research_master_id'].nil?
      rm = ResearchMaster.find_by(id: protocol['research_master_id'])
      unless rm.nil?
        rm.update_attribute(:sparc_id, Protocol.find_by(sparc_id: protocol['id']).id)
      end
    end
  end

  # eirb_studies.each do |study|
  #   unless study['research_master_id'].nil?
  #     validated_states = ['Acknowledged', 'Approved', 'Completed', 'Disapproved', 'Exempt Approved', 'Expired',  'Expired - Continuation in Progress', 'External IRB Review Archive', 'Not Human Subjects Research', 'Suspended', 'Terminated', 'Withdrawn']
  #     rm = ResearchMaster.find_by(id: study['research_master_id'])
  #     unless rm.nil?
  #       if Protocol.where(eirb_id: study['pro_number'], type: 'EIRB').present?
  #         rm.update_attribute(:eirb_id, Protocol.where(eirb_id: study['pro_number'], type: 'EIRB').first.id)
  #       end
  #       if validated_states.include?(study['state'])
  #         rm.update_attributes(short_title: study['short_title'], long_title: study['title'], eirb_validated: true)
  #       end
  #     end
  #   end
  # end
end
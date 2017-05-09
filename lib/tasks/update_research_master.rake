require 'dotenv/tasks'

task update_research_master: :environment do
  binding.pry
  sparc_api = ENV.fetch("SPARC_API")
  eirb_api =  ENV.fetch("EIRB_API")
  eirb_api_token = ENV.fetch("EIRB_API_TOKEN")
  protocols = HTTParty.get("#{sparc_api}/protocols", timeout: 500, headers: {'Content-Type' => 'application/json'})

  binding.pry
  protocols.each do |protocol|
    unless protocol['research_master_id'].nil?
      rm = ResearchMaster.find_by(id: protocol['research_master_id'])
      unless rm.nil?
        rm.update_attribute(:sparc_id, Protocol.find_by(sparc_id: protocol['id']).id)
      end
    end
  end
end
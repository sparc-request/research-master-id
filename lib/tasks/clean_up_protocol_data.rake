# Copyright © 2011-2020 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

task clean_up_protocol_data: :environment do

  def find_protocol(id, id_type, protocols)
    protocols.each do |protocol|
      if protocol[id_type] == id
        return protocol
      end
    end
  end

  eirb_api        = ENV.fetch("EIRB_API")
  eirb_api_token  = ENV.fetch("EIRB_API_TOKEN")
  sparc_api        = ENV.fetch("SPARC_API")
  
  puts "Gathering data..."

  sparc_protocols = HTTParty.get("#{sparc_api}/protocols", timeout: 500, headers: {'Content-Type' => 'application/json'})
  eirb_studies = HTTParty.get("#{eirb_api}/studies.json?musc_studies=true", timeout: 500, headers: {'Content-Type' => 'application/json', "Authorization" => "Token token=\"#{eirb_api_token}\""})

  null_eirb_pi_studies  = Protocol.where(type: 'EIRB').where(primary_pi_id: nil)
  null_sparc_pi_studies = Protocol.where(type: 'SPARC').where(primary_pi_id: nil)

  deleted_protocols = CSV.open("tmp/deleted_protocols.csv", "wb")
  deleted_protocols << ['ID', 'Type', 'Long Title', 'Eirb ID']

  pro_numbers = []
  eirb_studies.each do |study|
    pro_numbers << study['pro_number']
  end

  sparc_ids = []
  sparc_protocols.each do |protocol|
    sparc_ids << protocol['id']
  end

  puts 'Cleaning up Eirb studies...'

  null_eirb_pi_studies.each do |study|
    research_master = ResearchMaster.find_by_eirb_protocol_id(study.id)

    if pro_numbers.include?(study.eirb_id) && (research_master != nil)
      protocol = find_protocol(study.eirb_id, 'pro_number', eirb_studies)
      pi = User.find_by_email(protocol['pi_email'])
      unless pi == nil
        study.update_attributes(primary_pi_id: pi.id)
      end
    else
      deleted_protocols << [study.id, study.type, study.long_title, study.eirb_id]
      study.destroy
    end
  end

  puts 'Cleaning up Sparc protocols...'

  null_sparc_pi_studies.each do |study|
    research_master = ResearchMaster.find_by_sparc_protocol_id(study.id)

    if sparc_ids.include?(study.sparc_id) && (research_master != nil)
      protocol = find_protocol(study.sparc_id, 'id', sparc_protocols)
      pi = User.find_by_email(protocol['email'])
      unless pi == nil
        study.update_attributes(primary_pi_id: pi.id) 
      end
    else
      deleted_protocols << [study.id, study.type, study.long_title, study.sparc_id]
      study.destroy
    end
  end
end
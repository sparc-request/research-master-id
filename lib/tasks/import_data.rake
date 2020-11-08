# Copyright © 2020 MUSC Foundation for Research Development~
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

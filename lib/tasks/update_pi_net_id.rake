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

task update_pi_net_id: :environment do
  eirb_api = ENV.fetch('EIRB_API')
  eirb_api_token = ENV.fetch('EIRB_API_TOKEN')
  sparc_api = ENV.fetch('SPARC_API')

  protocols = HTTParty.get(
    "#{sparc_api}/protocols",
    timeout: 500,
    headers: { 'Content-Type' => 'application/json' }
  )
  eirb_studies = HTTParty.get("#{eirb_api}/studies.json?musc_studies=true",
                              timeout: 500, headers: {'Content-Type' => 'application/json',
                                                      "Authorization" => "Token token=\"#{eirb_api_token}\""})

  protocols.each do |protocol|
    if Protocol.exists?(sparc_id: protocol['id'])
      protocol_to_update = Protocol.find_by(sparc_id: protocol['id'])
      unless protocol_to_update.primary_pi.nil?
        pi = protocol_to_update.primary_pi
        pi.update_attribute(:net_id, protocol['ldap_uid'])
      end
    end
  end

  eirb_studies.each do |study|
    if Protocol.exists?(eirb_id: study['pro_number'])
      study_to_update = Protocol.find_by(eirb_id: study['pro_number'])
      unless study_to_update.primary_pi.nil?
        pi = study_to_update.primary_pi
        pi.update_attribute(:net_id, study['pi_net_id'])
      end
    end
  end
end

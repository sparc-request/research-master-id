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

require 'rails_helper'

RSpec.describe 'API::ValidatedRecords', type: :request do
  describe 'GET /api/validated_records' do
    # Hoist the setup variables
    let(:api_key) { create(:api_key) }
    let(:protocol) { create(:protocol, eirb_id: 'Pro#123456') }
    
    # Pre-populate 10 unvalidated records that should NOT be returned
    let!(:unvalidated_rms) { create_list(:research_master, 10) }
    
    # The one validated record that SHOULD be returned, created before the request via let!
    let!(:rm) do
      create(:research_master,
             eirb_validated: true,
             eirb_protocol_id: protocol.id)
    end

    it 'returns only validated research master records' do
      get "/api/validated_records.json", 
          params: {},
          headers: { Authorization: "Token token=#{api_key.access_token}" }

      expect(json.length).to eq(1)
      expect(json.first['id']).to eq(rm.id)
    end
  end
end

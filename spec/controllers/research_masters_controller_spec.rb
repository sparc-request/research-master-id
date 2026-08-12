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

RSpec.describe ResearchMastersController, type: :controller do
  describe 'GET #index' do
    let!(:user) { create(:user) }
    let!(:creator) { create(:user) }

    before do
      sign_in user
    end

    context 'no search params' do
      # Hoisted and created before the action via let!
      let!(:rm) { create(:research_master, pi: user, creator: creator) }

      it 'returns all research masters' do
        get :index
        expect(assigns(:research_masters).to_a).to eq([rm])
      end
    end

    context 'with search params' do
      # Use unique search strings to avoid ID collisions (e.g., '111' matching ID '9111')
      let(:eirb) { create(:protocol, eirb_id: '999111') }
      let(:coeus) { create(:protocol, mit_award_number: '999222') }
      let(:cayuse) { create(:protocol, cayuse_project_number: '999333') }

      # Create the records before the tests execute
      let!(:rm_with_eirb) { create(:research_master, short_title: 'eirb', pi: user, eirb_protocol: eirb, creator: creator) }
      let!(:rm_with_coeus) { create(:research_master, short_title: 'coeus', pi: user, creator: creator) }
      let!(:rm_with_cayuse) { create(:research_master, short_title: 'cayuse', pi: user, creator: creator) }

      before do
        # Establish relations for the tests
        ResearchMasterCoeusRelation.create!(research_master: rm_with_coeus, protocol: coeus)
        ResearchMasterCayuseRelation.create!(research_master: rm_with_cayuse, protocol: cayuse)
      end

      it 'filters by associations' do
        get :index, params: { q: { combined_search_cont: '999111' } }
        expect(assigns(:research_masters).to_a).to eq([rm_with_eirb])

        get :index, params: { q: { combined_search_cont: '999222' } }
        expect(assigns(:research_masters).to_a).to eq([rm_with_coeus])

        get :index, params: { q: { combined_search_cont: '999333' } }
        expect(assigns(:research_masters).to_a).to eq([rm_with_cayuse])
      end
    end
  end
end

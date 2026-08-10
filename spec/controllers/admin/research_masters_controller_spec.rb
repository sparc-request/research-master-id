# Copyright © 2024 MUSC Foundation for Research Development~
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

RSpec.describe Admin::ResearchMastersController, type: :controller do
  describe 'GET #index' do
    # Hoisted setup variables
    let(:is_admin) { true }
    let(:user) { create(:user, admin: is_admin) }

    before do
      # Clear existing data to prevent test pollution from fixtures, seeds, or previous suites
      ResearchMaster.delete_all
      sign_in user
    end

    context 'when a research master record has multiple associated protocols' do
      # use let! so the record is created before the action is called
      let!(:rm1) { create(:research_master, pi: user) }
      let(:protocol1) { create(:protocol) }
      let(:protocol2) { create(:protocol) }

      before do
        2.times { ResearchMasterCayuseRelation.create!(research_master: rm1, protocol_id: protocol1.id) }
        2.times { ResearchMasterCoeusRelation.create!(research_master: rm1, protocol_id: protocol2.id) }
      end

      it 'returns the unique set without duplicates' do
        get :index, params: { q: {} }
        expect(assigns(:research_masters).to_a).to match_array([rm1])
      end
    end

    context 'when sorting by ID' do
      let!(:rm1) { create(:research_master, pi: user) }
      let!(:rm2) { create(:research_master, pi: user, short_title: 'short title') }

      it 'sorts by research master id' do
        get :index
        expect(assigns(:research_masters).to_a).to eq([rm1, rm2])

        get :index, params: { q: { s: 'id desc' } }
        expect(assigns(:research_masters).to_a).to eq([rm2, rm1])
      end
    end

    context 'when user is not an admin' do
      let(:is_admin) { false }

      it 'redirects requests for /admin to sign-in/main page' do
        get :index
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when user is an admin' do
      let(:is_admin) { true }

      it 'allows access to /admin' do
        get :index
        expect(response).to be_successful
      end
    end
  end
end

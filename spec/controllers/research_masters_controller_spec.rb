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

describe ResearchMastersController, type: :controller do
  describe '#index' do

    it 'should return success' do
      user = create(:user)
      sign_in user

      get :index

      expect(response).to be_success
    end

    it 'should only allow signed in users' do
      get :index

      expect(response).to have_http_status(302)
    end
  end

  describe '#show' do

    it 'should only allow signed in users' do
      rm = create(:research_master)

      get :show, params: { id: rm, format: :js }

      expect(response).to have_http_status 401
    end

    it 'should return success' do
      user = create(:user)
      rm = create(:research_master)
      sign_in user

      get :show, params: { id: rm, format: :js }

      expect(response).to be_success
    end

    it 'should set instance variables' do
      protocol_one = create(:protocol, type: 'SPARC', primary_pi: create(:user, name: 'pi'))
      protocol_two = create(:protocol, type: 'EIRB', primary_pi: create(:user, name: 'pi'))
      user = create(:user)
      rm = create(:research_master,
                  sparc_protocol_id: protocol_one.id,
                  eirb_protocol_id: protocol_two.id
                  )
      sign_in user

      get :show, params: { id: rm, format: :js }

      expect(assigns(:sparc_protocol)).to eq protocol_one
      expect(assigns(:eirb_protocol)).to eq protocol_two
    end
  end

  describe '#new' do

    it 'should return success' do
      user = create(:user)
      sign_in user

      get :new, params: { format: :js }

      expect(response).to be_success
    end

    it 'should only allow signed in users' do
      get :new, params: { format: :js }

      expect(response).to have_http_status 401
    end

    it 'should return an instantiated object' do
      user = create(:user)
      sign_in user

      get :new, params: { format: :js }

      expect(assigns(:research_master)).to be_a_new(ResearchMaster)
    end
  end

  describe '#edit' do

    it 'should only allow signed in users' do
      rm = create(:research_master)

      get :edit, params: { id: rm, format: :js }

      expect(response).to have_http_status 401
    end

    it 'should return success' do
      user = create(:user)
      rm = create(:research_master)
      sign_in user

      get :edit, params: { id: rm, format: :js }

      expect(response).to be_success
    end
  end

  describe '#create' do
    it 'should create a RMID' do
      user = create(:user)
      sign_in user
      expect { post :create,
        params: {
          research_master: {
            long_title: 'long title',
            short_title: 'short',
            funding_source: 'source',
            research_type: 'clinical_billing',
            creator_id: user.id
          },
          pi_name: 'ooga',
          pi_email: 'booga@booga.com'
          },
        xhr: true
      }.to change(ResearchMaster, :count).by(1)
    end
  end

  describe '#update' do
    it 'should only allow signed in users' do
      rm = create(:research_master)

      patch :update, params: { id: rm, research_master: attributes_for(:research_master).except(:user), format: :js }

      expect(response).to have_http_status 401
    end
  end

  describe '#destroy' do

    it 'should only allow signed in users' do
      rm = create(:research_master)

      delete :destroy, params: { id: rm, format: :js }

      expect(response).to have_http_status 401
    end

    it 'should return success' do
      user = create(:user)
      rm = create(:research_master)
      sign_in user

      delete :destroy, params: { id: rm, format: :js }

      expect(response).to be_success
    end
  end
end


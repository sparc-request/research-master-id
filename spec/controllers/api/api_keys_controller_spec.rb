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

RSpec.describe Api::ApiKeysController, type: :controller do
  # Hoisted setup variables
  let(:is_developer) { false }
  let(:user) { create(:user, developer: is_developer) }

  before do
    sign_in user
  end

  describe 'GET #new' do
    context 'when user is not a developer' do
      # is_developer defaults to false
      it 'redirects the user' do
        get :new
        expect(response).to have_http_status(302)
      end
    end

    context 'when user is a developer' do
      # Override the default
      let(:is_developer) { true }

      it 'allows access' do
        get :new
        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'POST #create' do
    context 'when user is not a developer' do
      it 'redirects the user' do
        post :create
        expect(response).to have_http_status(302)
      end
    end

    context 'when user is a developer' do
      let(:is_developer) { true }

      it 'allows access' do
        post :create, xhr: true
        expect(response).to have_http_status(200)
      end

      it 'creates a new ApiKey record' do
        expect { post :create, xhr: true }.to change(ApiKey, :count).by(1)
      end
    end
  end
end


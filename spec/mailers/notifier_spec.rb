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

RSpec.describe Notifier do
  describe '#success' do
    # 1. Hoist the shared setup variables
    let(:owner) { create(:user, email: 'pi@email.com') }
    let(:rm_pi) { create(:user) }
    # Renamed from 'rm_id' to 'rm' since it is the full object, not just an integer
    let(:rm) { create(:research_master, creator: owner, pi: rm_pi) }
    
    # 2. Capture the original ENV state so we can restore it and prevent state bleed
    let(:original_env) { ENV['ENVIRONMENT'] }

    after do
      # Restore the environment variable after every test
      ENV['ENVIRONMENT'] = original_env
    end

    context 'when in production environment' do
      before do
        ENV['ENVIRONMENT'] = 'production'
      end

      it 'should have two recipients when an array is passed' do
        result = Notifier.success([owner.email, rm_pi.email], rm_pi, rm)
        expect(result.to).to eq [owner.email, rm_pi.email]
      end

      it 'should have the correct subject' do
        result = Notifier.success(owner.email, rm_pi, rm)
        expect(result.subject).to eq "Research Master Record Successfully Created (RMID: #{rm.id} - #{owner.email})"
      end

      it 'should be from donotreply@musc.edu' do
        result = Notifier.success(owner.email, rm_pi, rm)
        expect(result.from).to eq ['donotreply@musc.edu']
      end

      it 'should carry on and send to the specified recipient' do
        result = Notifier.success(owner.email, rm_pi, rm)
        expect(result.to).to eq [owner.email]
      end
    end

    context 'when in staging environment' do
      before do
        ENV['ENVIRONMENT'] = 'staging'
      end

      it 'should route all emails to the staging intercept address' do
        result = Notifier.success(owner.email, rm_pi, rm)
        expect(result.to).to eq ['sparcrequest@gmail.com']
      end
    end
  end
end


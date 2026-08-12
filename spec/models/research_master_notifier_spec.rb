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

RSpec.describe ResearchMasterNotifier, type: :model do
  before do
    ActionMailer::Base.deliveries.clear
  end

  describe '#send_mail' do
    let(:user) { create(:user) }
    let(:owner_email) { user.email }
    
    # The variable we pass into the Notifier
    let(:rm_pi) { nil } 
    
    # By default, let FactoryBot generate a valid PI in the background so it saves successfully
    let(:rm) do 
      create(:research_master,
             long_title: 'long',
             short_title: 'short',
             funding_source: 'funding',
             creator: user)
    end
    
    let(:rm_notifier) { ResearchMasterNotifier.new(rm_pi, owner_email, rm) }

    context 'when rm_pi is nil' do
      it 'still sends one email' do
        expect { rm_notifier.send_mail }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end

    context 'when user email is nil' do
      let(:owner_email) { nil }

      it 'still sends one email' do
        expect { rm_notifier.send_mail }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end

    context 'when owner and pi are different users' do
      let(:rm_pi) { create(:user) }
      
      # Override the factory here to explicitly link the database record to our rm_pi user
      let(:rm) do 
        create(:research_master,
               long_title: 'long',
               short_title: 'short',
               funding_source: 'funding',
               creator: user,
               pi: rm_pi)
      end

      it 'sends two emails' do
        expect { rm_notifier.send_mail }.to change { ActionMailer::Base.deliveries.count }.by(2)
      end
    end
  end
end

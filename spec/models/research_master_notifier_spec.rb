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

require 'rails_helper'

describe ResearchMasterNotifier do
  before { ActionMailer::Base.deliveries = [] }

  describe '#send_mail' do
    it 'should still send an email if rm_pi is nil' do
      user = create(:user)
      rm_id = create(:research_master,
                     long_title: 'long',
                     short_title: 'short',
                     funding_source: 'funding',
                     creator: user
                    )
      owner_email = user.email
      rm_notifier = ResearchMasterNotifier.new(nil, owner_email, rm_id)

      rm_notifier.send_mail

      expect(ActionMailer::Base.deliveries.count).to eq(1)
    end

    it 'should still send an email if user email is nil' do
      user = create(:user)
      rm_id = create(:research_master,
                     long_title: 'long',
                     short_title: 'short',
                     funding_source: 'funding',
                     creator: user
                    )
      rm_notifier = ResearchMasterNotifier.new(nil, nil, rm_id)

      rm_notifier.send_mail

      expect(ActionMailer::Base.deliveries.count).to eq(1)
    end

    it 'should send two emails if different' do
      user = create(:user)
      pi = create(:user)
      rm_id = create(:research_master,
                     long_title: 'long',
                     short_title: 'short',
                     funding_source: 'funding',
                     creator: user,
                     pi: pi)
      owner_email = user.email
      rm_notifier = ResearchMasterNotifier.new(pi, owner_email, rm_id)

      rm_notifier.send_mail

      expect(ActionMailer::Base.deliveries.count).to eq(2)
    end
  end
end

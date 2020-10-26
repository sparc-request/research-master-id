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

RSpec.describe Notifier do

  describe '#success' do

    it 'should have two recipients' do
      ENV["ENVIRONMENT"] = "production"
      owner = create(:user)
      rm_pi = create(:user)
      rm_id = create(:research_master, creator: owner, pi: rm_pi)

      result = Notifier.success([owner.email, rm_pi.email], rm_pi, rm_id)

      expect(result.to).to eq [owner.email, rm_pi.email]
    end

    it 'should have the correct subject' do
      owner = create(:user)
      rm_pi = create(:user)
      rm_id = create(:research_master, creator: owner, pi: rm_pi)

      result = Notifier.success(owner.email, rm_pi, rm_id)

      expect(result.subject).to eq "Research Master Record Successfully Created (RMID: #{rm_id.id} - #{owner.email})"
    end

    it 'it should be from no-reply@rmid.musc.edu' do
      owner = create(:user, email: 'pi@email.com')
      rm_pi = create(:user)
      rm_id = create(:research_master, creator: owner, pi: rm_pi)

      result = Notifier.success(owner.email, rm_pi, rm_id)

      expect(result.from).to eq ['donotreply@musc.edu']
    end

    it 'should send to gmail if env is staging' do
      ENV["ENVIRONMENT"] = "staging"
      owner = create(:user, email: 'pi@email.com')
      rm_pi = create(:user)
      rm_id = create(:research_master, creator: owner, pi: rm_pi)

      result = Notifier.success(owner.email, rm_pi, rm_id)

      expect(result.to).to eq ['sparcrequest@gmail.com']
    end

    it 'carry on if production' do
      ENV['ENVIRONMENT'] = 'production'
      owner = create(:user, email: 'pi@email.com')
      rm_pi = create(:user)
      rm_id = create(:research_master, creator: owner, pi: rm_pi)

      result = Notifier.success(owner.email, rm_pi, rm_id)

      expect(result.to).to eq [owner.email]
    end
  end
end


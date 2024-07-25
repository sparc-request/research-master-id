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

RSpec.describe ResearchMaster, type: :model do
  it { is_expected.to belong_to(:creator) }

  it { is_expected.to belong_to(:pi) }

  it { is_expected.to validate_length_of(:short_title).is_at_most(255) }

  it 'should validate on uniqueness of pi_name and long title when both are the same' do
    pi = create(:user)
    create(:research_master, pi: pi, long_title: 'long')
    research_master_two = build(:research_master, pi: pi, long_title: 'long')
    expect(research_master_two).not_to be_valid
  end

  it 'should validate on uniqueness of pi and long title when pi is different' do
    create(:research_master, pi: create(:user), long_title: 'long')
    research_master_two = build(:research_master, pi: create(:user), long_title: 'long')
    expect(research_master_two).to be_valid
  end

  it 'should validate on uniqueness of pi and long title when long title is different' do
    pi = create(:user)
    create(:research_master, pi: pi, long_title: 'long', short_title: 'short')
    research_master_two = build(:research_master, pi: pi, long_title: 'long2')
    expect(research_master_two).to be_valid
  end

  it 'should validate on uniqueness of pi and short title when both are the same' do
    pi = create(:user)
    create(:research_master, pi: pi, short_title: 'short', long_title: 'long')
    research_master_two = build(:research_master, pi: pi, short_title: 'short')
    expect(research_master_two).not_to be_valid
  end

  it 'should validate on uniqueness of pi and short title when short title is different' do
    pi = create(:user)
    create(:research_master, pi: pi, short_title: 'short', long_title: 'long')
    research_master_two = build(:research_master, pi: pi, short_title: 'short2')
    expect(research_master_two).to be_valid
  end

  describe '#validated' do
    it 'should return only records that have been validated by eirb' do
      rm_one = create(
        :research_master,
        eirb_validated: true
      )
      create(
        :research_master,
        eirb_validated: false
      )

      result = ResearchMaster.validated

      expect(result).to include(rm_one)
    end
    it 'should return only records that have been validated by eirb' do
      create(
        :research_master,
        eirb_validated: true
      )
      rm_two = create(
        :research_master,
        eirb_validated: false
      )

      result = ResearchMaster.validated

      expect(result).not_to include(rm_two)
    end
  end
end

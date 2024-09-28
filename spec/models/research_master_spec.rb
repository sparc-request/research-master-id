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

  let(:pi_a) { create(:user) }
  let(:pi_b) { create(:user) }

  context 'validate uniqueness of pi and long_title' do
    it 'is valid when pi is different' do
      create(:research_master, pi: pi_a, long_title: 'long')
      research_master_two = build(:research_master, pi: pi_b, long_title: 'long')
      expect(research_master_two).to be_valid
    end
    it 'is not valid when pi is the same' do
      create(:research_master, pi: pi_a, long_title: 'long')
      research_master_two = build(:research_master, pi: pi_a, long_title: 'long')
      expect(research_master_two).not_to be_valid
    end
  end

  context 'validate uniqueness of pi and short_title' do
    it 'is valid when pi is different' do
      create(:research_master, pi: pi_a, short_title: 'short')
      research_master_two = build(:research_master, pi: pi_b, short_title: 'short')
      expect(research_master_two).to be_valid
    end
    it 'is not valid when pi is the same' do
      create(:research_master, pi: pi_a, short_title: 'short')
      research_master_two = build(:research_master, pi: pi_a, short_title: 'short')
      expect(research_master_two).not_to be_valid
    end
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

  describe 'ransacker :combined_search' do
    context 'search across multiple fields' do
      it 'should find partial match' do
        user = create(:user, name: 'Jane P. Doe', last_name: 'Doe', first_name: 'Jane')
        rm = create(:research_master, short_title: 'short', creator: user, pi: user)
        result = ResearchMaster.with_associations_for_search.ransack(combined_search_cont: 'P.').result
        expect(result).to include(rm)
      end
    end
    context 'date reformatting' do
      it 'should reformat date to match db' do
        expect(ResearchMaster.reformat_to_match_db('1/1/2020')).to eq('2020-01-01')
      end
      it 'should find match after reformatting' do
        rm = create(:research_master, created_at: '2020-01-01')
        date_search = '1/1/20'
        reformat = ResearchMaster.reformat_to_match_db(date_search)
        result = ResearchMaster.with_associations_for_search.ransack(combined_search_cont: reformat).result
        expect(result).to include(rm)
      end
    end
  end
end

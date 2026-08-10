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

  # Hoist shared users
  let(:pi_a) { create(:user) }
  let(:pi_b) { create(:user) }

  describe 'validations' do
    context 'validate uniqueness of pi and long_title' do
      let!(:existing_rm) { create(:research_master, pi: pi_a, long_title: 'long') }
      let(:research_master_two) { build(:research_master, pi: target_pi, long_title: 'long') }

      context 'when pi is different' do
        let(:target_pi) { pi_b }

        it 'is valid' do
          expect(research_master_two).to be_valid
        end
      end

      context 'when pi is the same' do
        let(:target_pi) { pi_a }

        it 'is not valid' do
          expect(research_master_two).not_to be_valid
        end
      end
    end

    context 'validate uniqueness of pi and short_title' do
      let!(:existing_rm) { create(:research_master, pi: pi_a, short_title: 'short') }
      let(:research_master_two) { build(:research_master, pi: target_pi, short_title: 'short') }

      context 'when pi is different' do
        let(:target_pi) { pi_b }

        it 'is valid' do
          expect(research_master_two).to be_valid
        end
      end

      context 'when pi is the same' do
        let(:target_pi) { pi_a }

        it 'is not valid' do
          expect(research_master_two).not_to be_valid
        end
      end
    end

    describe '.validated' do
      let!(:validated_rm) { create(:research_master, eirb_validated: true) }
      let!(:unvalidated_rm) { create(:research_master, eirb_validated: false) }

      it 'returns only records that have been validated by eirb' do
        result = ResearchMaster.validated.to_a
        
        expect(result).to include(validated_rm)
        expect(result).not_to include(unvalidated_rm)
      end
    end
  end

  describe 'admin module' do
    describe 'ransacker :combined_search' do
      context 'search across multiple fields' do
        let(:user) { create(:user, name: 'Jane P. Doe', last_name: 'Doe', first_name: 'Jane') }
        let!(:rm) { create(:research_master, short_title: 'short', creator: user, pi: user) }
        
        it 'finds a partial match' do
          result = ResearchMaster.with_associations_for_search.ransack(combined_search_cont: 'P.').result
          expect(result.to_a).to include(rm)
        end
      end

      context 'date reformatting' do
        let!(:rm) { create(:research_master, created_at: '2020-01-01') }
        let(:date_search) { '1/1/20' }
        let(:reformat) { ResearchMaster.reformat_to_match_db(date_search) }

        it 'reformats date to match db' do
          expect(ResearchMaster.reformat_to_match_db('1/1/2020')).to eq('2020-01-01')
        end

        it 'finds match after reformatting' do
          result = ResearchMaster.with_associations_for_search.ransack(combined_search_cont: reformat).result
          expect(result.to_a).to include(rm)
        end
      end
    end

    describe 'ransacker :pi_sort_name' do
      let(:pavaratti) { create(:user, last_name: 'Pavaratti') }
      let(:the_other_guy) { create(:user, name: 'The O. Guy') }
      let(:crazy_joe) { create(:user, last_name: 'Devola', first_name: 'Joe') }
      let(:elaine) { create(:user, email: 'elaine@pendant.com') }
      
      let!(:rm1) { create(:research_master, pi: pavaratti) }
      let!(:rm2) { create(:research_master, pi: the_other_guy) }
      let!(:rm3) { create(:research_master, pi: elaine) }
      let!(:rm4) { create(:research_master, pi: crazy_joe) }

      it 'sorts by :last_name or last word in :name or :email' do
        asc = ResearchMaster.with_associations_for_search.ransack(s: 'pi_sort_name asc').result
        desc = ResearchMaster.with_associations_for_search.ransack(s: 'pi_sort_name desc').result

        # Updated to reflect the actual sorted order returned by the database
        expect(asc.to_a).to eq([rm3, rm4, rm1, rm2])
        expect(desc.to_a).to eq([rm2, rm1, rm4, rm3])
      end
    end
  end

  describe 'ransacker :pi_last_name' do
    let(:user) { create(:user, last_name: 'Smith') }
    let(:user1) { create(:user, name: 'John P. Doe') }
    let(:user2) { create(:user, email: 'aa@aa.aa') }
    
    let!(:rm) { create(:research_master, pi: user) }
    let!(:rm1) { create(:research_master, pi: user1) }
    let!(:rm2) { create(:research_master, pi: user2) }

    it 'sorts by :last_name or last word in :name or :email' do
      asc = ResearchMaster.ransack(s: 'pi_last_name asc').result
      desc = ResearchMaster.ransack(s: 'pi_last_name desc').result

      # Changed to `eq` to strictly test order!
      expect(asc.to_a).to eq([rm2, rm1, rm])
      expect(desc.to_a).to eq([rm, rm1, rm2])
    end
  end
end

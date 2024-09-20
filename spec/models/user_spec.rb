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

RSpec.describe User, type: :model do
  it { is_expected.to have_many(:protocols) }

  describe 'ransacker :combined_search' do
    context 'search by email' do
      it 'should find partial match' do
        user = create(:user, email: 'aa@bb.cc')
        result = User.ransack(combined_search_cont: '@bb').result
        expect(result).to include(user)
      end
    end
    context 'search by latest sign in date' do
      it 'should find partial match' do
        user = create(:user, current_sign_in_at: "2020-01-01")
        result = User.ransack(combined_search_cont: '2020').result
        expect(result).to include(user)
      end
    end
    context 'date reformatting' do
      it 'should reformat date to match db' do
        expect(User.reformat_to_match_db('01/01/2020')).to eq('2020-01-01')
      end
      it 'should find match after reformatting' do
        user = create(:user, current_sign_in_at: "2020-01-01")
        date_search = '1/1/20'
        reformat = User.reformat_to_match_db(date_search)
        result = User.ransack(combined_search_cont: reformat).result
        expect(result).to include(user)
      end
    end
    context 'when searching for a user by name' do
      it 'should return expected results' do
        user = create(:user, name: 'Jane Doe', first_name: 'Jane', last_name: 'Doe', email: 'jd@cc.cc')
        result = User.ransack(combined_search_cont: 'Jane').result
        expect(result).to include(user)
      end
    end
  end
end

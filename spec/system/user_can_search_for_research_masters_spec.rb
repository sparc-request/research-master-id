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
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~0
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

require 'rails_helper'

RSpec.describe 'Research Master Search', type: :system, js: true do
  # Lazy-load these variables so they don't execute until explicitly called
  let(:user) { User.first }
  let(:research_master) { create(:research_master, creator: user) }

  before do
    create_and_sign_in_user
    
    # Trigger the let block now that the user exists in the test database
    research_master 
    visit root_path
  end

  it 'does not show records when there are no valid results' do
    fill_in 'q_short_title_cont', with: 'Some Absolute Nonsense'
    find('form#research_master_search input.btn.btn-success').click

    # Capybara natively waits for the AJAX response to remove this content
    expect(page).not_to have_content(research_master.short_title)
  end

  it 'shows the searched for rmid' do
    fill_in 'q_short_title_cont', with: research_master.short_title
    find('form#research_master_search input.btn.btn-success').click

    # Capybara natively waits for the AJAX response to display this content
    expect(page).to have_content(research_master.short_title)
  end
end

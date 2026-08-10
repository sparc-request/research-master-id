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

RSpec.describe 'Creating a new research master record', type: :system, js: true do
  before do
    create_and_sign_in_user
    visit root_path
    
    # Capybara will automatically wait for this button to be ready and clickable
    find('.create-research-master').click
  end

  it 'does not allow submit when PI is missing' do
    # Capybara automatically waits for the form to appear before filling these in
    fill_in 'research_master_pi_name', with: ''
    fill_in 'pi_department', with: 'My Pills'
    fill_in 'research_master_long_title', with: 'Long John'
    fill_in 'research_master_short_title', with: 'Shortstop'

    expect(page).to have_button('Submit', disabled: true)
  end

  it 'allows department to be blank' do
    fill_in 'research_master_pi_name', with: 'Julia'
    fill_in 'pi_department', with: ''
    fill_in 'research_master_long_title', with: 'Long John'
    fill_in 'research_master_short_title', with: 'Shortstop'
    
    click_button 'Submit'

    expect(page).not_to have_css('div.form-group.has-error')
  end

  it 'renders form errors about long title' do
    fill_in 'research_master_pi_name', with: 'Julia'
    fill_in 'pi_department', with: 'my pills'
    fill_in 'research_master_long_title', with: ''
    fill_in 'research_master_short_title', with: 'Shortstop'
    
    click_button 'Submit'

    expect(page).to have_css('div.form-group.has-error')
    expect(page).to have_css('span.help-block', text: "Can't be blank")
  end

  it 'renders form errors about short title' do
    fill_in 'research_master_pi_name', with: 'Julia'
    fill_in 'pi_department', with: 'my pills'
    fill_in 'research_master_long_title', with: 'long john'
    fill_in 'research_master_short_title', with: ''
    
    click_button 'Submit'

    expect(page).to have_css('div.form-group.has-error')
    expect(page).to have_css('span.help-block', text: "Can't be blank")
  end

  # TODO: This test doesn't actually pass for real, we need to refactor how the api's are connected to work on this (pi search doesn't work, throws error)
  # it 'does not render form errors when all fields are filled out' do
  #   fill_in 'research_master_pi_name', with: 'Julia'
  #   fill_in 'pi_department', with: 'my pills'
  #   fill_in 'research_master_long_title', with: 'long john'
  #   fill_in 'research_master_short_title', with: 'short'
  #   choose 'research_master_funding_source_internal'
  #   select "Basic Science Research", from: "research_master_research_type"
  #
  #   click_button 'Submit'
  #
  #   expect(page).not_to have_css('div.form-group.has-error')
  # end
end


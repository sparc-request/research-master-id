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

RSpec.describe 'User should be able to create a new research master record', js: true do

  describe 'creating new reserch master record' do

    it 'should not allow submit when PI is missing' do
      create_and_sign_in_user

      find('.create-research-master').click
      wait_for_ajax
      fill_in 'research_master_pi_name', with: ''
      fill_in 'pi_department', with: 'My Pills'
      fill_in 'research_master_long_title', with: 'Long John'
      fill_in 'research_master_short_title', with: 'Shortstop'
      choose 'research_master_funding_source_internal'
      select "Basic Science Research", :from => "research_master_research_type"

      expect(page).to have_button('Submit', disabled: true)
    end

    it 'should allow department to be blank' do
      create_and_sign_in_user

      find('.create-research-master').click
      wait_for_ajax
      fill_in 'research_master_pi_name', with: 'billy'
      fill_in 'pi_department', with: ''
      fill_in 'research_master_long_title', with: 'Long John'
      fill_in 'research_master_short_title', with: 'Shortstop'
      choose 'research_master_funding_source_internal'
      select "Basic Science Research", :from => "research_master_research_type"
      click_button 'Submit'
      wait_for_ajax

      expect(page).not_to have_css('div.form-group.has-error')
    end

    it 'should render form errors about long title' do
      create_and_sign_in_user

      find('.create-research-master').click
      wait_for_ajax
      fill_in 'research_master_pi_name', with: 'billy'
      fill_in 'pi_department', with: 'my pills'
      fill_in 'research_master_long_title', with: ''
      fill_in 'research_master_short_title', with: 'Shortstop'
      choose 'research_master_funding_source_internal'
      select "Basic Science Research", :from => "research_master_research_type"
      click_button 'Submit'
      wait_for_ajax

      expect(page).to have_css('div.form-group.has-error')
      expect(page).to have_css('span.help-block', text: "Can't be blank")
    end

    it 'should render form errors about short title' do
      create_and_sign_in_user

      find('.create-research-master').click
      wait_for_ajax
      fill_in 'research_master_pi_name', with: 'billy'
      fill_in 'pi_department', with: 'my pills'
      fill_in 'research_master_long_title', with: 'long john'
      fill_in 'research_master_short_title', with: ''
      choose 'research_master_funding_source_internal'
      select "Basic Science Research", :from => "research_master_research_type"
      click_button 'Submit'
      wait_for_ajax

      expect(page).to have_css('div.form-group.has-error')
      expect(page).to have_css('span.help-block', text: "Can't be blank")
    end

    it 'should render form errors about funding source' do
      create_and_sign_in_user

      find('.create-research-master').click
      wait_for_ajax
      fill_in 'research_master_pi_name', with: 'billy'
      fill_in 'pi_department', with: 'my pills'
      fill_in 'research_master_long_title', with: 'long john'
      fill_in 'research_master_short_title', with: 'short'
      select "Basic Science Research", :from => "research_master_research_type"
      click_button 'Submit'
      wait_for_ajax

      expect(page).to have_css('div.form-group.has-error')
      expect(page).to have_css('span.help-block', text: "Can't be blank")
    end

    it 'should render form errors about research type' do
      create_and_sign_in_user

      find('.create-research-master').click
      wait_for_ajax
      fill_in 'research_master_pi_name', with: 'billy'
      fill_in 'pi_department', with: 'my pills'
      fill_in 'research_master_long_title', with: 'long john'
      fill_in 'research_master_short_title', with: 'short'
      choose 'research_master_funding_source_internal'
      click_button 'Submit'
      wait_for_ajax

      expect(page).to have_css('div.form-group.has-error')
      expect(page).to have_css('span.help-block', text: "Can't be blank")
    end

    it 'should not render form errors when all fields are filled out' do
      create_and_sign_in_user

      find('.create-research-master').click
      wait_for_ajax
      fill_in 'research_master_pi_name', with: 'billy'
      fill_in 'pi_department', with: 'my pills'
      fill_in 'research_master_long_title', with: 'long john'
      fill_in 'research_master_short_title', with: 'short'
      choose 'research_master_funding_source_internal'
      select "Basic Science Research", :from => "research_master_research_type"
      click_button 'Submit'
      wait_for_ajax

      expect(page).not_to have_css('div.form-group.has-error')
    end

    #it 'should render form errors for special characters in short title' do
    #  create_and_sign_in_user
#
#      find('.create-research-master').click
#      wait_for_ajax
#      fill_in 'research_master_pi_name', with: 'Hans'
#      fill_in 'pi_department', with: 'Franz'
#      fill_in 'research_master_long_title', with: 'Long Shot'
#      fill_in 'research_master_short_title', with: '±˙˜ƒ√ç'
#      choose 'research_master_funding_source_internal'
#      click_button 'Submit'
#      wait_for_ajax

#      expect(page).to have_content('Special characters are not allowed in the Short Title')
#    end

    #it 'should render form errors for special characters in long title' do
    #  create_and_sign_in_user

    #  find('.create-research-master').click
    #  wait_for_ajax
    #  fill_in 'research_master_pi_name', with: 'Hans'
    #  fill_in 'pi_department', with: 'Franz'
    #  fill_in 'research_master_long_title', with: '±˙˜ƒ√ç'
    #  fill_in 'research_master_short_title', with: 'Short Round'
    #  choose 'research_master_funding_source_internal'
    #  click_button 'Submit'
    #  wait_for_ajax

    #  expect(page).to have_content('Special characters are not allowed in the Long Title')
    #end
  end
end


require 'rails_helper'

feature 'User should be able to create a new research master record', js: true do

  describe 'creating new reserch master record' do

    it 'should create a new record upon form submission' do
      create_and_sign_in_user

      find('.create-research-master').click
      wait_for_ajax
      fill_in 'research_master_pi_name', with: 'Billy'
      fill_in 'research_master_department', with: 'My Pills'
      fill_in 'research_master_long_title', with: 'Long John'
      fill_in 'research_master_short_title', with: 'Shortstop'
      choose 'research_master_funding_source_internal'
      choose 'research_master_research_type_basic_science_research'
      click_button 'Submit'
      wait_for_ajax

      expect(ResearchMaster.count).to eq 1
    end

    it 'should render form errors' do
      create_and_sign_in_user

      find('.create-research-master').click
      wait_for_ajax
      fill_in 'research_master_pi_name', with: ''
      fill_in 'research_master_department', with: 'My Pills'
      fill_in 'research_master_long_title', with: 'Long John'
      fill_in 'research_master_short_title', with: 'Shortstop'
      choose 'research_master_funding_source_internal'
      click_button 'Submit'
      wait_for_ajax

      expect(page).to have_css('div.form-group.has-error')
      expect(page).to have_css('span.help-block', text: "Can't be blank")
    end

    it 'should render form errors' do
      create_and_sign_in_user

      find('.create-research-master').click
      wait_for_ajax
      fill_in 'research_master_pi_name', with: 'billy'
      fill_in 'research_master_department', with: ''
      fill_in 'research_master_long_title', with: 'Long John'
      fill_in 'research_master_short_title', with: 'Shortstop'
      choose 'research_master_funding_source_internal'
      click_button 'Submit'
      wait_for_ajax

      expect(page).to have_css('div.form-group.has-error')
      expect(page).to have_css('span.help-block', text: "Can't be blank")
    end

    it 'should render form errors' do
      create_and_sign_in_user

      find('.create-research-master').click
      wait_for_ajax
      fill_in 'research_master_pi_name', with: 'billy'
      fill_in 'research_master_department', with: 'my pills'
      fill_in 'research_master_long_title', with: ''
      fill_in 'research_master_short_title', with: 'Shortstop'
      choose 'research_master_funding_source_internal'
      click_button 'Submit'
      wait_for_ajax

      expect(page).to have_css('div.form-group.has-error')
      expect(page).to have_css('span.help-block', text: "Can't be blank")
    end

    it 'should render form errors' do
      create_and_sign_in_user

      find('.create-research-master').click
      wait_for_ajax
      fill_in 'research_master_pi_name', with: 'billy'
      fill_in 'research_master_department', with: 'my pills'
      fill_in 'research_master_long_title', with: 'long john'
      fill_in 'research_master_short_title', with: ''
      choose 'research_master_funding_source_internal'
      click_button 'Submit'
      wait_for_ajax

      expect(page).to have_css('div.form-group.has-error')
      expect(page).to have_css('span.help-block', text: "Can't be blank")
    end

    it 'should render form errors' do
      create_and_sign_in_user

      find('.create-research-master').click
      wait_for_ajax
      fill_in 'research_master_pi_name', with: 'billy'
      fill_in 'research_master_department', with: 'my pills'
      fill_in 'research_master_long_title', with: 'long john'
      fill_in 'research_master_short_title', with: 'short'
      click_button 'Submit'
      wait_for_ajax

      expect(page).to have_css('div.form-group.has-error')
      expect(page).to have_css('span.help-block', text: "Can't be blank")
    end

    it 'should render form errors for special characters in short title' do
      create_and_sign_in_user

      find('.create-research-master').click
      wait_for_ajax
      fill_in 'research_master_pi_name', with: 'Hans'
      fill_in 'research_master_department', with: 'Franz'
      fill_in 'research_master_long_title', with: 'Long Shot'
      fill_in 'research_master_short_title', with: '±˙˜ƒ√ç'
      choose 'research_master_funding_source_internal'
      click_button 'Submit'
      wait_for_ajax
      
      expect(page).to have_content('Special characters are not allowed in the Short Title')
    end

    it 'should render form errors for special characters in long title' do
      create_and_sign_in_user

      find('.create-research-master').click
      wait_for_ajax
      fill_in 'research_master_pi_name', with: 'Hans'
      fill_in 'research_master_department', with: 'Franz'
      fill_in 'research_master_long_title', with: '±˙˜ƒ√ç'
      fill_in 'research_master_short_title', with: 'Short Round'
      choose 'research_master_funding_source_internal'
      click_button 'Submit'
      wait_for_ajax
      
      expect(page).to have_content('Special characters are not allowed in the Long Title')
    end
  end
end


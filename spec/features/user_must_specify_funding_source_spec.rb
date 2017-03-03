require 'rails_helper'

feature 'User must specify funding source', js: true do
  scenario 'successfully shows errors' do
    create_and_sign_in_user

    click_link 'Create Research Master ID'
    fill_in 'research_master_pi_name', with: 'User'
    fill_in 'research_master_department', with: 'Department'
    fill_in 'research_master_long_title', with: 'Long'
    fill_in 'research_master_short_title', with: 'short'

    click_button 'Submit'

    expect(page).to have_content "Can't be blank"
  end
  scenario 'successfully does not show errors' do
    create_and_sign_in_user

    click_link 'Create Research Master ID'
    fill_in 'research_master_pi_name', with: 'William Holt'
    fill_in 'research_master_department', with: 'Department'
    fill_in 'research_master_long_title', with: 'Long'
    fill_in 'research_master_short_title', with: 'short'
    choose 'research_master_funding_source_internal'

    click_button 'Submit'

    expect(page).not_to have_content "Can't be blank"
  end
end


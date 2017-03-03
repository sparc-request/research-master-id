require 'rails_helper'

feature 'User edits rm', js: true do
  scenario 'successfully' do
    create_and_sign_in_user
    user = User.first
    rm = create(:research_master,
                user: user,
                eirb_validated: false,
                pi_name: 'billy',
                department: 'My Pills',
                long_title: 'Long John',
                short_title: 'Shortstop',
                funding_source: 'External'
               )

    find("a.edit-#{rm.id}").click
    fill_in 'research_master_pi_name', with: 'Dr. Strange'
    fill_in 'research_master_department', with: 'ooga'
    fill_in 'research_master_long_title', with: 'booga'
    fill_in 'research_master_short_title', with: 'billy...my pills'
    choose 'research_master_funding_source_internal'
    click_button 'Submit'

    expect(page).to have_content 'Dr. Strange'
    expect(page).to have_content 'ooga'
    expect(page).to have_content 'booga'
    expect(page).to have_content 'billy...my pills'
    expect(page).to have_content 'Internal'
  end

  scenario 'successfully' do
    create_and_sign_in_user
    user = User.first
    user_two = create(:user)
    user.update_attribute(:admin, true)
    rm = create(:research_master,
                user: user_two,
                eirb_validated: false,
                pi_name: 'billy',
                department: 'My Pills',
                long_title: 'Long John',
                short_title: 'Shortstop',
                funding_source: 'External'
               )

    find("a.edit-#{rm.id}").click
    fill_in 'research_master_pi_name', with: 'Dr. Strange'
    fill_in 'research_master_department', with: 'ooga'
    fill_in 'research_master_long_title', with: 'booga'
    fill_in 'research_master_short_title', with: 'billy...my pills'
    choose 'research_master_funding_source_internal'
    click_button 'Submit'

    expect(page).to have_content 'Dr. Strange'
    expect(page).to have_content 'ooga'
    expect(page).to have_content 'booga'
    expect(page).to have_content 'billy...my pills'
    expect(page).to have_content 'Internal'
  end


  scenario 'regular user attempting to edit other user rm' do
    create_and_sign_in_user
    user = create(:user)
    rm = create(:research_master,
                user: user,
                eirb_validated: false,
                pi_name: 'billy',
                department: 'My Pills',
                long_title: 'Long John',
                short_title: 'Shortstop',
                funding_source: 'External'
               )

    expect(page).to have_css("a.edit-#{rm.id}.disabled")
  end

  scenario 'rm-eirb validated' do
    create_and_sign_in_user
    user = User.first
    rm = create(:research_master,
                user: user,
                pi_name: 'billy',
                department: 'My Pills',
                long_title: 'Long John',
                short_title: 'Shortstop',
                funding_source: 'External',
                eirb_validated: true
               )

    expect(page).to have_css("a.edit-#{rm.id}.disabled")
  end
end


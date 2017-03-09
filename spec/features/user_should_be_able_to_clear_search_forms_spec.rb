require 'rails_helper'

feature 'User should be able to clear search forms', js: true do
  scenario 'successfully - research masters' do
    create_and_sign_in_user
    find('#show_more').click

    fill_in 'q_pi_name_cont', with: 'blah blah'
    fill_in 'q_short_title_cont', with: 'blah blah'
    fill_in 'q_long_title_cont', with: 'blah blah'
    fill_in 'q_funding_source_cont', with: 'blah blah'
    fill_in 'q_id_eq', with: 'blah blah'
    fill_in 'q_department_cont', with: 'ooga'
    click_button 'Clear Search Form'

    expect(page).to have_field 'q_pi_name_cont', with: ''
    expect(page).to have_field 'q_short_title_cont', with: ''
    expect(page).to have_field 'q_long_title_cont', with: ''
    expect(page).to have_field 'q_funding_source_cont', with: ''
    expect(page).to have_field 'q_id_eq', with: ''
    expect(page).to have_field 'q_department_cont', with: ''
  end

  scenario 'successfully - protocols' do
    create_and_sign_in_user
    User.first.update_attribute(:admin, true)
    visit protocols_path

    fill_in 'q_sparc_id_eq', with: 'blah blah'
    fill_in 'q_eirb_id_cont', with: 'blah blah'
    fill_in 'q_primary_pi_name_cont', with: 'blah blah'
    fill_in 'q_long_title_cont', with: 'blah blah'
    click_button 'Clear Search Form'

    expect(page).to have_field 'q_sparc_id_eq', with: ''
    expect(page).to have_field 'q_eirb_id_cont', with: ''
    expect(page).to have_field 'q_primary_pi_name_cont', with: ''
    expect(page).to have_field 'q_long_title_cont', with: ''
  end
end


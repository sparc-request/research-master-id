require 'rails_helper'

feature 'User selects pi name when creating rm record', js: true do
  scenario 'enables button when selecting pi name from suggestion' do
    create_and_sign_in_user

    click_link 'Create Research Master ID'

    expect(page).to have_button('Submit', disabled: true)
    fill_in 'research_master_pi_name', with: 'Holt'
    wait_for_ajax
    execute_script("$('.tt-suggestion:first-child').trigger('click');")
    wait_for_ajax

    expect(page).to have_css('#research_master_pi_name[disabled]')
    expect(page).to have_button('Submit', disabled: false)
  end

  scenario 'disables button if text is emptied out' do
    create_and_sign_in_user

    click_link 'Create Research Master ID'

    expect(page).to have_button('Submit', disabled: true)
    fill_in 'research_master_pi_name', with: 'Holt'
    wait_for_ajax
    execute_script("$('.tt-suggestion:first-child').trigger('click');")
    wait_for_ajax
    click_link 'Reset'
    fill_in 'research_master_pi_name', with: ''
    fill_in 'research_master_department', with: 'department'

    expect(page).to have_button('Submit', disabled: true)
  end

  scenario 'reset buttons allows you to re-enter text' do
    create_and_sign_in_user

    click_link 'Create Research Master ID'

    expect(page).to have_button('Submit', disabled: true)
    fill_in 'research_master_pi_name', with: 'Holt'
    wait_for_ajax
    execute_script("$('.tt-suggestion:first-child').trigger('click');")
    wait_for_ajax

    expect(page).to have_css('#research_master_pi_name[disabled]')
    expect(page).to have_button('Submit', disabled: false)

    click_link 'Reset'

    expect(page).not_to have_css('#research_master_pi_name[disabled]')
    expect(page).to have_button('Submit', disabled: true)
  end
end


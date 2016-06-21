require 'rails_helper'

feature 'User should see their research masters', js:true do
  scenario 'successfully' do
    user = create(:user)
    research_master = create(:research_master, user: user)
    visit new_user_session_path
    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: user.password
    click_button 'Log in'

    wait_for_ajax

    expect(page).to have_content research_master.short_title
  end
end

require 'rails_helper'

feature 'User should see research master index' do
  scenario 'successfully' do
    user = create(:user)
    visit new_user_session_path
    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: user.password
    click_button 'Log in'

    expect(current_path).to eq root_path
    expect(page).to have_css 'table'
  end
end

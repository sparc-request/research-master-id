require 'rails_helper'

feature 'User should be able to create new research master record' do
  scenario 'successfully' do
    user = create(:user)
    visit new_user_session_path
    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: user.password
    click_button 'Log in'

    click_link 'Create New'

    expect(page).to have_css 'form'
  end
end

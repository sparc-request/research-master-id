require 'rails_helper'

feature 'User should see hamburger icon if admin', js: true do
  scenario 'successfully' do
    create_and_sign_in_user
    user = User.first
    user.update_attribute(:admin, true)

    expect(page).to have_css('#menu-toggle')
  end

  scenario 'user' do
    create_and_sign_in_user

    expect(page).not_to have_css('#menu-toggle')
  end
end


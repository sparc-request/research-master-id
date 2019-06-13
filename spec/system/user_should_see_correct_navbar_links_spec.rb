require 'rails_helper'

RSpec.describe 'User should see correct navbar links', js: true do

  scenario 'developer' do
    create_and_sign_in_user
    user = User.first
    user.update_attribute(:developer, true)

    visit root_path

    expect(page).to have_css('a', text: 'API')
  end

  scenario 'user' do
    create_and_sign_in_user

    visit root_path

    expect(page).not_to have_css('a', text: 'API')
  end
end


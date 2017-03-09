require 'rails_helper'

feature 'Developer should proceed to API portal', js: true do
  before :each do
    create_and_sign_in_user
    user = User.first
    user.update_attribute(:developer, true)
  end

  scenario 'successfully' do
    visit root_path

    click_link 'API'

    expect(page).to have_css('a', text: 'Generate API Key')
  end

  scenario 'get a new api key' do
    visit root_path

    click_link 'API'
    click_link 'Generate API Key'

    expect(page).to have_field('api_key')
    expect(page).to have_css('button.copy-key')
  end
end

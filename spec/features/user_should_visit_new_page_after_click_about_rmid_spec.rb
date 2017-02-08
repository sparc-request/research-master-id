require 'rails_helper'

feature 'User should visit new page after clicking About RMID', js: true do
  scenario 'successfully' do
    create_and_sign_in_user
    visit root_path

    click_link 'About RMID'

    page.driver.browser.window_focus page.windows.last.handle

    expect(URI.parse(current_url).to_s).to eq 'https://www.musc.edu/rmid'
  end
end


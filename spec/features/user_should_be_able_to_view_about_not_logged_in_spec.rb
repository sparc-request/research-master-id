require 'rails_helper'

feature 'User should be able to view about not logged in', js: true do
  scenario 'successfully' do
    visit root_path
    click_link 'About RMID'

    expect(page).to have_content(
      'A Research Master ID (RMID) is a unique numeric identifier that links a research study across multiple MUSC research systems.'
    )
  end
end

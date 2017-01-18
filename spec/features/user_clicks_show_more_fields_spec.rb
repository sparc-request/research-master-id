require 'rails_helper'

feature 'User clicks show more fields', js: true do
  scenario 'successfully' do
    create_and_sign_in_user

    create(:research_master, user: User.first)

    check 'show_more'

    click_button 'Search'

    expect(page).to have_selector('#optional-search-fields', visible: true)
  end

  scenario 'successfully' do
    create_and_sign_in_user

    create(:research_master, user: User.first)

    check 'show_more'

    uncheck 'show_more'

    click_button 'Search'

    expect(page).to have_selector('#optional-search-fields', visible: false)
  end
end

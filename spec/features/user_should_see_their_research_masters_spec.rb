require 'rails_helper'

feature 'User should see their research masters', js:true do
  scenario 'successfully' do
    create_and_sign_in_user

    research_master = create(:research_master, creator: User.first)

    expect(page).to have_content research_master.short_title
  end
end

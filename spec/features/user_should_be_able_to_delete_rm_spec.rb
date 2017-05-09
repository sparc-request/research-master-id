require 'rails_helper'

feature 'User should be able to delete rm', js: true do

  scenario 'successfully as user' do
    create_and_sign_in_user
    user = User.first
    create(:research_master, user: user)

    find('a.research-master-delete').click
    within '.sweet-alert.visible' do
      click_button 'Delete'
    end
    wait_for_ajax

    expect(ResearchMaster.count).to eq 0
  end

  scenario 'successfully as admin' do
    create_and_sign_in_user
    user = User.first
    user_two = create(:user)
    user.update_attribute(:admin, true)
    create(:research_master, user: user_two)

    find('a.research-master-delete').click
    within '.sweet-alert.visible' do
      click_button 'Delete'
    end
    wait_for_ajax

    expect(ResearchMaster.count).to eq 0
  end

  scenario 'disable link if not users/admin' do
    create_and_sign_in_user
    user_two = create(:user)
    create(:research_master, user: user_two)

    expect(page).to have_css 'a.research-master-delete.disabled'
  end
  
end


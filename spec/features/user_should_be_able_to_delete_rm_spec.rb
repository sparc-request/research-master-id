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

  scenario 'delete just associated record as user' do
    create_and_sign_in_user
    user = User.first
    rm = create(:research_master, user: user)
    create(:associated_record, research_master: rm)

    find('a.dropdown-toggle').click
    click_link 'Delete Association Only'
    within '.sweet-alert.visible' do
      click_button 'Delete'
    end
    wait_for_ajax

    expect(AssociatedRecord.count).to eq 0
  end

  scenario 'delete just associated record as admin' do
    create_and_sign_in_user
    user = User.first
    user_two = create(:user)
    user.update_attribute(:admin, true)
    rm = create(:research_master, user: user_two)
    create(:associated_record, research_master: rm)

    find('a.dropdown-toggle').click
    click_link 'Delete Association Only'
    within '.sweet-alert.visible' do
      click_button 'Delete'
    end
    wait_for_ajax

    expect(AssociatedRecord.count).to eq 0
  end

  scenario 'delete rm and associated records as user' do
    create_and_sign_in_user
    user = User.first
    rm = create(:research_master, user: user)
    create(:associated_record, research_master: rm)

    find('a.dropdown-toggle').click
    click_link 'Delete'
    within '.sweet-alert.visible' do
      click_button 'Delete'
    end
    wait_for_ajax

    expect(AssociatedRecord.count).to eq 0
    expect(ResearchMaster.count).to eq 0
  end

  scenario 'delete just associated record as admin' do
    create_and_sign_in_user
    user = User.first
    user_two = create(:user)
    user.update_attribute(:admin, true)
    rm = create(:research_master, user: user_two)
    create(:associated_record, research_master: rm)

    find('a.dropdown-toggle').click
    click_link 'Delete'
    within '.sweet-alert.visible' do
      click_button 'Delete'
    end
    wait_for_ajax

    expect(AssociatedRecord.count).to eq 0
    expect(ResearchMaster.count).to eq 0
  end
end


require 'rails_helper'

feature 'User creates research master and associated record', js: true do
  scenario 'successfully' do
    pi = create(:primary_pi, name: 'big daddy')
    pi_two = create(:primary_pi, name: 'big dawg')
    protocol_one = create(:protocol,
                          type: 'SPARC',
                          sparc_id: 9737,
                          primary_pi: pi,
                          long_title: 'Mr. Meeseeks'
                         )
    protocol_two = create(:protocol,
                          type: 'EIRB',
                          eirb_id: 'prosomething',
                          primary_pi: pi_two,
                          long_title: 'billy my pills...'
                         )
    create_and_sign_in_user
    user = User.first
    user.update_attributes(admin: true, developer: true)

    visit protocols_path
    fill_in 'q_primary_pi_name_cont', with: 'big'
    click_button 'Search'
    check "protocol_#{protocol_one.id}"
    check "protocol_#{protocol_two.id}"
    click_link 'Associate Protocols'
    wait_for_ajax
    fill_in 'research_master_pi_name', with: 'Billy'
    fill_in 'research_master_department', with: 'My Pills'
    fill_in 'research_master_long_title', with: 'Long John'
    fill_in 'research_master_short_title', with: 'Shortstop'
    choose 'research_master_funding_source_internal'
    click_button 'Submit'
    wait_for_ajax

    expect(AssociatedRecord.count).to eq 1
    expect(ResearchMaster.count).to eq 1
  end
end

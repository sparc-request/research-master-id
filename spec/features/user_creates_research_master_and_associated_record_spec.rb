require 'rails_helper'

feature 'User creates research master and associated record', js: true do
  scenario 'successfully' do
    identity_one = create(:identity)
    identity_two = create(:identity)
    protocol_one = create(:protocol)
    protocol_two = create(:protocol)
    create(:project_role, role: 'primary-pi', identity: identity_one, protocol_id: protocol_one )
    create(:project_role, role: 'primary-pi', identity: identity_two, protocol_id: protocol_two )
    create_and_sign_in_user

    check "protocol_#{protocol_one.id}"
    check "protocol_#{protocol_two.id}"

    click_link 'Associate Records'
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

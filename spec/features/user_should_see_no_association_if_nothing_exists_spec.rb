require 'rails_helper'

feature 'User should see no association if nothing exists', js: true do
  scenario 'successfully' do
    create(:research_master)
    create_and_sign_in_user

    first('.research-master').click

    expect(page).to have_css 'h1.text-center', text: 'No Associated Protocols'
  end

  scenario 'successfully' do
    rm = create(:research_master)
    sparc_protocol = create(:protocol, type: 'SPARC')
    eirb_protocol = create(:protocol, type: 'EIRB')
    primary_pi = create(:primary_pi, protocol: sparc_protocol)
    primary_pi = create(:primary_pi, protocol: eirb_protocol)
    create(:associated_record, research_master: rm, sparc_id: sparc_protocol.id, eirb_id: eirb_protocol.id)
    create_and_sign_in_user

    first('.research-master').click

    expect(page).to have_content sparc_protocol.long_title
    expect(page).to have_content eirb_protocol.long_title
  end

end

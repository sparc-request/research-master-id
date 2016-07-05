require 'rails_helper'

feature 'User searches for primary pi' do
  scenario 'successfully' do
    create_and_sign_in_user

    click_link 'Look Up'

    fill_in 'q_primary_pi_cont', with: 'billy'

    click_button 'Submit'

    expect(page).to have_css 'td', text: 'billy'
  end
end

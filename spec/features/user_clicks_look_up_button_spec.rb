require 'rails_helper'

feature 'User clicks look up button', js:true do
  scenario 'successfully' do
    create_and_sign_in_user

    click_link 'Look Up'

    expect(current_path).to eq protocols_path
  end
end

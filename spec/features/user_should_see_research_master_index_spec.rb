require 'rails_helper'

feature 'User should see research master index' do
  scenario 'successfully' do
    create_and_sign_in_user

    expect(current_path).to eq root_path
    expect(page).to have_css 'table'
  end
end

require 'rails_helper'

feature 'User succesfully signs in', js:true do
  scenario 'successfully' do
    create_and_sign_in_user

    expect(current_path).to eq root_path
  end
end

require 'rails_helper'

RSpec.describe 'User succesfully signs in', js:true do
  scenario 'successfully' do
    create_and_sign_in_user

    expect(current_path).to eq root_path
  end
end

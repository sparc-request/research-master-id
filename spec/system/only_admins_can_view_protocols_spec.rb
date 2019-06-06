require 'rails_helper'

RSpec.describe 'Only admins can view protocols', js: true do
  scenario 'admin' do
    create_and_sign_in_user
    user = User.first
    user.update_attribute(:admin, true)

    visit protocols_path

    expect(current_path).to eq protocols_path
  end

  scenario 'admin' do
    create_and_sign_in_user

    visit protocols_path

    expect(current_path).to eq root_path
    expect(page).to have_css('div.alert.alert-danger.fade.in', text: "x\nYou must have administrative rights to view/associate Protocols")
  end
end

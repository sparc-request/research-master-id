module CreateAndSignInUser

  def create_and_sign_in_user
    user = create(:user)
    visit new_user_session_path
    fill_in 'user_login', with: user.email
    fill_in 'user_password', with: user.password
    click_button 'Log in'
  end
end

RSpec.configure do |config|
  config.include CreateAndSignInUser
end

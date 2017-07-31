require 'rails_helper'

describe DirectoriesController, type: :controller do
  render_views

  describe '#index' do
    it 'should return json ldap data based on user input param' do
      user = create(:user)
      sign_in user

      get :show, params: { name: 'will', format: :json }

      expect(response).to be_success
    end
  end
end


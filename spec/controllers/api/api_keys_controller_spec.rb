require 'rails_helper'

describe Api::ApiKeysController, type: :controller do
  describe '#new' do
    it 'should only allow developers' do
      user = create(:user)
      sign_in user

      get :new

      expect(response).to have_http_status 302
    end

    it 'should only allow developers' do
      user = create(:user, developer: true)
      sign_in user

      get :new

      expect(response).to have_http_status 200
    end
  end
  describe '#create' do

    it 'should only allow developers' do
      user = create(:user)
      sign_in user

      post :create

      expect(response).to have_http_status 302
    end

    it 'should only allow developers' do
      user = create(:user, developer: true)
      sign_in user

      xhr :post, 'create'

      expect(response).to have_http_status 200
    end
    it 'should only allow developers' do
      user = create(:user, developer: true)
      sign_in user

      expect{ xhr :post, 'create' }.to change(ApiKey, :count).by(1)
    end
  end
end


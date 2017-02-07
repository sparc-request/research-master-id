require 'rails_helper'

describe DetailsController, type: :controller do
  describe '#show' do
    it 'should return success without logging in' do
      get :show, format: :js

      expect(response).to have_http_status(200)
    end
  end
end

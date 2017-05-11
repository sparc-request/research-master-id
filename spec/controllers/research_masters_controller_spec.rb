require 'rails_helper'

describe ResearchMastersController, type: :controller do
  describe '#index' do

    it 'should return success' do
      user = create(:user)
      sign_in user

      get :index

      expect(response).to be_success
    end

    it 'should only allow signed in users' do
      get :index

      expect(response).to have_http_status(302)
    end
  end

  describe '#show' do

    it 'should only allow signed in users' do
      rm = create(:research_master)

      get :show, id: rm, format: :js

      expect(response).to have_http_status 401
    end

    it 'should return success' do
      user = create(:user)
      rm = create(:research_master)
      sign_in user

      get :show, id: rm, format: :js

      expect(response).to be_success
    end

    it 'should set instance variables' do
      protocol_one = create(:protocol, type: 'SPARC')
      protocol_two = create(:protocol, type: 'EIRB')
      user = create(:user)
      rm = create(:research_master,
                  sparc_protocol_id: protocol_one.id,
                  eirb_protocol_id: protocol_two.id
                  )
      sign_in user

      get :show, id: rm, format: :js

      expect(assigns(:sparc_protocol)).to eq protocol_one
      expect(assigns(:eirb_protocol)).to eq protocol_two
    end
  end

  describe '#new' do

    it 'should return success' do
      user = create(:user)
      sign_in user

      get :new, format: :js

      expect(response).to be_success
    end

    it 'should only allow signed in users' do
      get :new, format: :js

      expect(response).to have_http_status 401
    end

    it 'should return an instantiated object' do
      user = create(:user)
      sign_in user

      get :new, format: :js

      expect(assigns(:research_master)).to be_a_new(ResearchMaster)
    end
  end

  describe '#edit' do

    it 'should only allow signed in users' do
      rm = create(:research_master)

      get :edit, id: rm, format: :js

      expect(response).to have_http_status 401
    end

    it 'should return success' do
      user = create(:user)
      rm = create(:research_master)
      sign_in user

      get :edit, id: rm, format: :js

      expect(response).to be_success
    end
  end

  describe '#create' do
    it 'should create a RMID' do
      user = create(:user)
      sign_in user

      expect { xhr :post, 'create', research_master: {
        pi_name: 'William Holt',
        department: 'department',
        long_title: 'long title',
        short_title: 'short',
        funding_source: 'source',
        user_id: user.id
      },
      pi_name: 'ooga',
      pi_email: 'booga@booga.com'
      }.to change(ResearchMaster, :count).by(1)
    end

    it 'should send two emails - one to owner and pi' do
      user = create(:user)
      sign_in user

      expect { xhr :post, 'create', research_master: {
        pi_name: 'William Holt',
        department: 'department',
        long_title: 'long title',
        short_title: 'short',
        funding_source: 'source',
        user_id: user.id
      },
      pi_name: 'pi-man',
      pi_email: 'primary-pi@gmail.com'
      }.to change(ActionMailer::Base.deliveries, :count).by(2)
    end

    it 'should send one email if same email address' do
      user = create(:user)
      sign_in user

      expect { xhr :post, 'create', research_master: {
        pi_name: 'William Holt',
        department: 'department',
        long_title: 'long title',
        short_title: 'short',
        funding_source: 'source',
        user_id: user.id
      },
      pi_name: 'William Holt',
      pi_email: "#{user.email}"
      }.to change(ActionMailer::Base.deliveries, :count).by(1)
    end

    it 'should create a RM PI' do
      user = create(:user)
      sign_in user

      expect { xhr :post, 'create', research_master: {
        pi_name: 'William Holt',
        department: 'department',
        long_title: 'long title',
        short_title: 'short',
        funding_source: 'source',
        user_id: user.id
      },
      pi_name: 'pi man',
      pi_email: 'pi-guy@pi.com'
      }.to change(ResearchMasterPi, :count).by(1)
    end

    it 'should still send an email if RM PI is nil' do
      user = create(:user)
      sign_in user

      expect { xhr :post, 'create', research_master: {
        pi_name: 'William Holt',
        department: 'department',
        long_title: 'long title',
        short_title: 'short',
        funding_source: 'source',
        user_id: user.id
      },
      pi_name: nil,
      pi_email: nil
      }.to change(ActionMailer::Base.deliveries, :count).by(1)
    end

    it 'should still create a RM object if RM PI nil' do
      user = create(:user)
      sign_in user

      expect { xhr :post, 'create', research_master: {
        pi_name: 'William Holt',
        department: 'department',
        long_title: 'long title',
        short_title: 'short',
        funding_source: 'source',
        user_id: user.id
      },
      pi_name: nil,
      pi_email: nil
      }.to change(ResearchMaster, :count).by(1)
    end

  end

  describe '#update' do
    it 'should return success' do
      user = create(:user)
      rm = create(:research_master)
      sign_in user

      patch :update, id: rm, research_master: attributes_for(:research_master), format: :js

      expect(response).to be_success
    end

    it 'should only allow signed in users' do
      rm = create(:research_master)

      patch :update, id: rm, research_master: attributes_for(:research_master), format: :js

      expect(response).to have_http_status 401
    end
  end

  describe '#destroy' do

    it 'should only allow signed in users' do
      rm = create(:research_master)

      delete :destroy, id: rm, format: :js

      expect(response).to have_http_status 401
    end

    it 'should return success' do
      user = create(:user)
      rm = create(:research_master)
      sign_in user

      delete :destroy, id: rm, format: :js

      expect(response).to be_success
    end
  end
end


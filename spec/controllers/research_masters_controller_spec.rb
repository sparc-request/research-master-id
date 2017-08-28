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

      get :show, params: { id: rm, format: :js }

      expect(response).to have_http_status 401
    end

    it 'should return success' do
      user = create(:user)
      rm = create(:research_master)
      sign_in user

      get :show, params: { id: rm, format: :js }

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

      get :show, params: { id: rm, format: :js }

      expect(assigns(:sparc_protocol)).to eq protocol_one
      expect(assigns(:eirb_protocol)).to eq protocol_two
    end
  end

  describe '#new' do

    it 'should return success' do
      user = create(:user)
      sign_in user

      get :new, params: { format: :js }

      expect(response).to be_success
    end

    it 'should only allow signed in users' do
      get :new, params: { format: :js }

      expect(response).to have_http_status 401
    end

    it 'should return an instantiated object' do
      user = create(:user)
      sign_in user

      get :new, params: { format: :js }

      expect(assigns(:research_master)).to be_a_new(ResearchMaster)
    end
  end

  describe '#edit' do

    it 'should only allow signed in users' do
      rm = create(:research_master)

      get :edit, params: { id: rm, format: :js }

      expect(response).to have_http_status 401
    end

    it 'should return success' do
      user = create(:user)
      rm = create(:research_master)
      sign_in user

      get :edit, params: { id: rm, format: :js }

      expect(response).to be_success
    end
  end

  describe '#create' do
    it 'should create a RMID' do
      user = create(:user)
      sign_in user
      expect { post :create, 
        params: {
          research_master: {
            pi_name: 'William Holt',
            department: 'department',
            long_title: 'long title',
            short_title: 'short',
            funding_source: 'source',
            research_type: 'clinical_billing',
            creator_id: user.id
          },
          pi_name: 'ooga',
          pi_email: 'booga@booga.com'
          }, 
        xhr: true
      }.to change(ResearchMaster, :count).by(1)
    end

    it 'should send two emails - one to owner and pi' do
      user = create(:user)
      sign_in user

      expect { post :create, 
        params: {
          research_master: {
            pi_name: 'William Holt',
            department: 'department',
            long_title: 'long title',
            short_title: 'short',
            funding_source: 'source',
            research_type: 'clinical_billing',
            creator_id: user.id
          },
          pi_name: 'pi-man',
          pi_email: 'primary-pi@gmail.com'
        },
        xhr: true
      }.to change(ActionMailer::Base.deliveries, :count).by(2)
    end
  end

  describe '#update' do
    it 'should return success' do
      user = create(:user)
      sign_in user
      rm = create(:research_master)
      patch :update, params: { id: rm, research_master: attributes_for(:research_master).except(:user), format: :js }

      expect(response).to be_success
    end

    it 'should only allow signed in users' do
      rm = create(:research_master)

      patch :update, params: { id: rm, research_master: attributes_for(:research_master).except(:user), format: :js }

      expect(response).to have_http_status 401
    end
  end

  describe '#destroy' do

    it 'should only allow signed in users' do
      rm = create(:research_master)

      delete :destroy, params: { id: rm, format: :js }

      expect(response).to have_http_status 401
    end

    it 'should return success' do
      user = create(:user)
      rm = create(:research_master)
      sign_in user

      delete :destroy, params: { id: rm, format: :js }

      expect(response).to be_success
    end
  end
end


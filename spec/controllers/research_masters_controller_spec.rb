require 'rails_helper'

describe ResearchMastersController, type: :controller do
  describe '#create' do
    it 'should create a RMID' do
      user = create(:user)
      sign_in user

      expect { post :create, research_master: {
        pi_name: 'William Holt',
        department: 'department',
        long_title: 'long title',
        short_title: 'short',
        funding_source: 'source',
        user_id: user.id
      }, format: :js,
      pi_name: 'ooga',
      pi_email: 'booga@booga.com'
      }.to change(ResearchMaster, :count).by(1)
    end

    it 'should send two emails - one to owner and pi' do
      user = create(:user)
      sign_in user

      expect { post :create, research_master: {
        pi_name: 'William Holt',
        department: 'department',
        long_title: 'long title',
        short_title: 'short',
        funding_source: 'source',
        user_id: user.id
      },
      format: :js,
      pi_name: 'pi-man',
      pi_email: 'primary-pi@gmail.com'
      }.to change(ActionMailer::Base.deliveries, :count).by(2)
    end

    it 'should send one email if same email address' do
      user = create(:user)
      sign_in user

      expect { post :create, research_master: {
        pi_name: 'William Holt',
        department: 'department',
        long_title: 'long title',
        short_title: 'short',
        funding_source: 'source',
        user_id: user.id
      },
      format: :js,
      pi_name: 'William Holt',
      pi_email: "#{user.email}"
      }.to change(ActionMailer::Base.deliveries, :count).by(1)
    end

    it 'should create a RM PI' do
      user = create(:user)
      sign_in user

      expect { post :create, research_master: {
        pi_name: 'William Holt',
        department: 'department',
        long_title: 'long title',
        short_title: 'short',
        funding_source: 'source',
        user_id: user.id
      },
      format: :js,
      pi_name: 'pi man',
      pi_email: 'pi-guy@pi.com'
      }.to change(ResearchMasterPi, :count).by(1)
    end

    it 'should still send an email if RM PI is nil' do
      user = create(:user)
      sign_in user

      expect { post :create, research_master: {
        pi_name: 'William Holt',
        department: 'department',
        long_title: 'long title',
        short_title: 'short',
        funding_source: 'source',
        user_id: user.id
      },
      format: :js,
      pi_name: nil,
      pi_email: nil
      }.to change(ActionMailer::Base.deliveries, :count).by(1)
    end

    it 'should still create a RM object if RM PI nil' do
      user = create(:user)
      sign_in user

      expect { post :create, research_master: {
        pi_name: 'William Holt',
        department: 'department',
        long_title: 'long title',
        short_title: 'short',
        funding_source: 'source',
        user_id: user.id
      },
      format: :js,
      pi_name: nil,
      pi_email: nil
      }.to change(ResearchMaster, :count).by(1)
    end

  end
end


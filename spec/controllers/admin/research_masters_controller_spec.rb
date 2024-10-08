require 'rails_helper'

RSpec.describe Admin::ResearchMastersController, type: :controller do
  describe 'GET #index' do
    context 'when a research master record has multiple associated protocols' do
      it 'returns the unique set without duplicates' do
        user = create(:user)
        sign_in user
        rm1 = create(:research_master, pi: user)

        protocol = create(:protocol)
        protocol1 = create(:protocol)

        2.times do
          ResearchMasterCayuseRelation.create!(research_master: rm1, protocol_id: protocol.id)
        end
        2.times do
          ResearchMasterCoeusRelation.create!(research_master: rm1, protocol_id: protocol1.id)
        end

        get :index, params: { q: {} }

        expect(assigns(:research_masters).to_a).to match_array([rm1])
      end
    end

    it 'sorts by research master id' do
      user = create(:user)
      sign_in user
      rm1 = create(:research_master, pi: user)
      rm2 = create(:research_master, pi: user, short_title: 'short title')

      get :index

      expect(assigns(:research_masters)).to eq([rm1, rm2])

      get :index, params: { q: { s: 'id desc' } }

      expect(assigns(:research_masters)).to eq([rm2, rm1])
    end

  end
end

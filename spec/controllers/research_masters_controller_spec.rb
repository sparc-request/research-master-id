require 'rails_helper'

RSpec.describe ResearchMastersController, type: :controller do
  describe 'GET #index' do
    let!(:user) { create(:user) }
    let!(:creator) { create(:user) }

    before do
      sign_in user
    end

    context 'no search params' do
      it 'returns all research masters' do
        rm = create(:research_master, pi: user, creator: creator)

        get :index
        expect(assigns(:research_masters)).to eq([rm])
      end

    end

    context 'with search params' do
      it 'filters by associations' do
        eirb = create(:protocol, eirb_id: '111')
        coeus = create(:protocol, mit_award_number: '222')
        cayuse = create(:protocol, cayuse_project_number: '333')

        rm_with_eirb = create(:research_master, short_title: 'eirb',pi: user, eirb_protocol: eirb, creator: creator)
        rm_with_coeus = create(:research_master, short_title: 'coeus', pi: user, creator: creator)
        ResearchMasterCoeusRelation.create!(research_master: rm_with_coeus, protocol: coeus)
        rm_with_cayuse = create(:research_master, short_title: 'cayuse', pi: user, creator: creator)
        ResearchMasterCayuseRelation.create!(research_master: rm_with_cayuse, protocol: cayuse)

        get :index, params: { q: { combined_search_cont: '111' } }
        expect(assigns(:research_masters)).to eq([rm_with_eirb])

        get :index, params: { q: { combined_search_cont: '222' } }
        expect(assigns(:research_masters)).to eq([rm_with_coeus])

        get :index, params: { q: { combined_search_cont: '333' } }
        expect(assigns(:research_masters)).to eq([rm_with_cayuse])
      end
    end
  end
end

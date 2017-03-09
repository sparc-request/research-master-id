require 'rails_helper'

describe AssociatedRecordsController, type: :controller do
  describe '#destroy' do

    it 'should only be accessed by a signed in user' do
      rm = create(:research_master)
      ar = create(:associated_record, research_master: rm)

      xhr :delete, 'destroy', research_master_id: rm, id: ar.id

      expect(response).to have_http_status 401
    end

    it 'should delete ar' do
      user = create(:user)
      sign_in user
      rm = create(:research_master)
      ar = create(:associated_record, research_master: rm)

      expect {
        xhr :delete,
        'destroy',
        research_master_id: rm,
        id: ar.id 
      }.to change(AssociatedRecord, :count).by(-1)
    end
  end
end

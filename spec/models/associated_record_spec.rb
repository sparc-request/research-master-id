require 'rails_helper'

RSpec.describe AssociatedRecord, type: :model do
  it { is_expected.to belong_to(:research_master) }

  context 'associated protocol ids' do

    it 'should return a list of all protocol ids associates with an RM record' do
      protocol1 = create(:protocol)
      protocol2 = create(:protocol)
      research_master1 = create(:research_master)
      research_master2 = create(:research_master, pi_name: 'brady')
      create(:associated_record, research_master_id: research_master1, sparc_id: protocol1.id)
      create(:associated_record, research_master_id: research_master2, sparc_id: protocol2.id)

      expect(AssociatedRecord.associated_protocol_ids).to eq([protocol1.id, protocol2.id])
    end
  end
end

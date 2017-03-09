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

  describe '#update_rm' do
    it 'should update rm' do
      rm = create(:research_master)
      eirb_protocol = create(:protocol,
                             type: 'EIRB',
                             eirb_state: 'Approved',
                             short_title: 'ooga',
                             long_title: 'booga'
                            )
      ar = create(:associated_record, eirb_id: eirb_protocol.id, research_master: rm)
      ar.update_rm

      expect(rm.short_title).to eq eirb_protocol.short_title
      expect(rm.long_title).to eq eirb_protocol.long_title
      expect(rm.eirb_validated).to eq true
    end

    context 'eirb_id nil' do
      it 'should not update rm' do
        rm = create(:research_master)
        ar = create(:associated_record, eirb_id: nil, research_master: rm)
        ar.update_rm

        expect(rm.short_title).to eq rm.short_title
        expect(rm.long_title).to eq rm.long_title
        expect(rm.eirb_validated).to eq false
      end
    end
  end
end


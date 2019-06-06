require 'rails_helper'

RSpec.describe ResearchMaster, type: :model do
  it { is_expected.to belong_to(:creator) }

  it { is_expected.to belong_to(:pi) }

  it { is_expected.to validate_length_of(:short_title).is_at_most(255) }

  it { is_expected.to validate_presence_of(:funding_source) }

  it 'should validate on uniqueness of pi_name and long title when both are the same' do
    pi = create(:user, name: 'pi')
    create(:research_master,
          pi: pi,
          long_title: 'long'
         )
    research_master_two = build(:research_master,
                                pi: pi,
                                long_title: 'long'
                               )

    expect(research_master_two).not_to be_valid
  end

  it 'should validate on uniqueness of pi_name and long title when pi is different' do
    create(:research_master,
          pi: create(:user, name: 'pi'),
          long_title: 'long'
         )
    research_master_two = build(:research_master,
                                pi: create(:user, name: 'brady'),
                                long_title: 'long'
                               )

    expect(research_master_two).to be_valid
  end

  it 'should validate on uniqueness of pi_name and long title when long title is different' do
    pi = create(:user, name: 'pi')
    create(:research_master,
          pi: pi,
          long_title: 'long'
         )
    research_master_two = build(:research_master,
                                pi: pi,
                                long_title: 'long2'
                               )

    expect(research_master_two).to be_valid
  end

  describe '#validated' do
    it 'should return only records that have been validated by eirb' do
      rm_one = create(
        :research_master,
        eirb_validated: true
      )
      create(
        :research_master,
        eirb_validated: false
      )

      result = ResearchMaster.validated

      expect(result).to include(rm_one)
    end
    it 'should return only records that have been validated by eirb' do
      create(
        :research_master,
        eirb_validated: true
      )
      rm_two = create(
        :research_master,
        eirb_validated: false
      )

      result = ResearchMaster.validated

      expect(result).not_to include(rm_two)
    end
  end
end


require 'rails_helper'

RSpec.describe ResearchMaster, type: :model do
  it { is_expected.to belong_to(:user) }

  it { is_expected.to have_one(:associated_record) }

  it { is_expected.to have_one(:research_master_pi) }

  it { is_expected.to validate_length_of(:long_title).is_at_most(255) }
  it { is_expected.to validate_length_of(:short_title).is_at_most(255) }

  it 'should validate on uniqueness of pi_name, department and long title' do
    create(:research_master,
          pi_name: 'pi',
          department: 'department',
          long_title: 'long'
         )
    research_master_two = build(:research_master,
                                pi_name: 'pi',
                                department: 'department',
                                long_title: 'long'
                               )

    expect(research_master_two).not_to be_valid
  end

  it 'should validate on uniqueness of pi_name, department and long title' do
    create(:research_master,
          pi_name: 'pi',
          department: 'department',
          long_title: 'long'
         )
    research_master_two = build(:research_master,
                                pi_name: 'brady',
                                department: 'department',
                                long_title: 'long'
                               )

    expect(research_master_two).to be_valid
  end

  it 'should validate on uniqueness of pi_name, department and long title' do
    create(:research_master,
          pi_name: 'pi',
          department: 'department',
          long_title: 'long'
         )
    research_master_two = build(:research_master,
                                pi_name: 'pi',
                                department: 'department2',
                                long_title: 'long'
                               )

    expect(research_master_two).to be_valid
  end

  it 'should validate on uniqueness of pi_name, department and long title' do
    create(:research_master,
          pi_name: 'pi',
          department: 'department',
          long_title: 'long'
         )
    research_master_two = build(:research_master,
                                pi_name: 'pi',
                                department: 'department',
                                long_title: 'long2'
                               )

    expect(research_master_two).to be_valid
  end
end


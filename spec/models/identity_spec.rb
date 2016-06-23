require 'rails_helper'

RSpec.describe Identity, type: :model do

  it { is_expected.to have_many(:project_roles) }

  context 'primary pi list' do

    it "should return a full list of identities that are primary_pi's" do
      identity1 = create(:identity, first_name: 'Will', last_name: 'Holt')
      project_role1 = create(:project_role, identity: identity1, role: 'primary-pi')
      identity2 = create(:identity, first_name: 'Jason', last_name: 'Leonard')
      project_role2 = create(:project_role, identity: identity2, role: 'consultant')

      expect(Identity.primary_pi_list).to eq(['Holt, Will'])
    end
  end
end
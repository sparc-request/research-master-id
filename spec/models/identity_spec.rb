require 'rails_helper'

RSpec.describe Identity, type: :model, truncation: true do

  it { is_expected.to have_many(:project_roles) }

  context 'primary pi list' do

    it "should return a full list of identities that are primary_pi's" do
      identity1 = create(:identity, first_name: 'Will', last_name: 'Holt')
      create(:project_role, identity: identity1, role: 'primary-pi')
      identity2 = create(:identity, first_name: 'Jason', last_name: 'Leonard')
      create(:project_role, identity: identity2, role: 'consultant')

      result = Identity.primary_pi_list

      expect(result).to eq([identity1])
    end

    it "should not return any identities that are not primary_pi's" do
      identity1 = create(:identity, first_name: 'Will', last_name: 'Holt')
      create(:project_role, identity: identity1, role: 'primary-pi')
      identity2 = create(:identity, first_name: 'Jason', last_name: 'Leonard')
      create(:project_role, identity: identity2, role: 'consultant')

      result = Identity.primary_pi_list

      expect(result).not_to eq([identity2])
    end
  end
end

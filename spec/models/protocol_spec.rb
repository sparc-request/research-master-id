require 'rails_helper'

RSpec.describe Protocol, type: :model do
  it { is_expected.to belong_to(:primary_pi) }
  it { is_expected.to have_many(:research_master_coeus_relations) }
  it { is_expected.to have_many(:research_masters) }
end

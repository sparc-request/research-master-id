require 'rails_helper'

RSpec.describe ResearchMaster, type: :model do
  it { is_expected.to belong_to(:user) }

  it { is_expected.to have_one(:associated_record) }
end

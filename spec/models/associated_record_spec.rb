require 'rails_helper'

RSpec.describe AssociatedRecord, type: :model do
  it { is_expected.to belong_to(:research_master) }
end

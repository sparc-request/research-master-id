require 'rails_helper'

RSpec.describe Protocol, type: :model do
  it { is_expected.to have_one(:primary_pi) }
end

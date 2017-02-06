require 'rails_helper'

describe ResearchMasterPi do

  it { is_expected.to belong_to(:research_master) }

  it { is_expected.to have_db_column(:name) }

  it { is_expected.to have_db_column(:email) }

  it { is_expected.to have_db_column(:department) }

  it { is_expected.to have_db_column(:research_master_id) }

  it { is_expected.to have_db_index(:research_master_id) }

  it { is_expected.to validate_presence_of(:name) }

  it { is_expected.to validate_presence_of(:email) }

  it { is_expected.to allow_value('something@something.com').for(:email) }

  it { is_expected.not_to allow_value('fljakdjflj').for(:email) }
end

require 'rails_helper'

describe 'update_data' do
  #include_context 'rake'

  it 'queries sparc api' do
    uri = URI('https://api-sparc.musc.edu/protocols')

    response = JSON.load(Net::HTTP.get(uri))

    expect(response.first['id']).to eq(2070)
  end
end

require 'rails_helper'

describe '#index', type: :request do
  it 'retrieves research master objects - #index' do
    create_list(:research_master, 10)
    api_key = create(:api_key)

    get '/api/research_masters.json', params: {},
      headers: {
      Authorization: "Token token=#{api_key.access_token}"
    }

    expect(json.length).to eq(10)
  end
end


require 'rails_helper'

describe '#show', type: :request do
  it 'should retrieve a specific RM record - #show' do
    rm = create(:research_master)
    api_key = create(:api_key)

    get "/api/research_masters/#{rm.id}.json", params: {},
      headers: {
      Authorization: "Token token=#{api_key.access_token}"
    }

    expect(json['id']).to eq rm.id
  end
end


require 'rails_helper'

describe '#index', type: :request do
  it 'should return validated rm records' do
    create_list(:research_master, 10)
    create_list(:research_master, 5, eirb_validated: true)
    api_key = create(:api_key)

    get "/api/validated_records.json", params: {},
      headers: { Authorization: "Token token=#{api_key.access_token}" }

    expect(json.length).to eq(5)
    expect(json.first['eirb_validated']).to eq true
  end
end

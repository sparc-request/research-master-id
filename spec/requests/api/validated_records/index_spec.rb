require 'rails_helper'

describe '#index', type: :request do
  it 'should return validated rm records' do
    protocol = create(:protocol, eirb_id: 'Pro#123456')
    create_list(:research_master, 10)
    rm = create(:research_master,
                eirb_validated: true,
                eirb_protocol_id: protocol.id)
    api_key = create(:api_key)

    get "/api/validated_records.json", params: {},
      headers: { Authorization: "Token token=#{api_key.access_token}" }

    expect(json.length).to eq(1)
    expect(json.first['id']).to eq rm.id
  end
end

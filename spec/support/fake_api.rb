require 'sinatra/base'

class FakeApi < Sinatra::Base
  get '/protocols' do
    json_response(200, 'sparc_protocols.json')
  end

  get '/studies.json' do
    json_response(200, 'eirb_protocols.json')
  end

  get '/award_details' do
    json_response(200, 'award_details.json')
  end

  get '/awards_hrs' do
    json_response(200, 'awards_hrs.json')
  end

  private

  def json_response(response_code, file_name)
    content_type :json
    status response_code
    File.open(File.dirname(__FILE__) + '/fixtures/' + file_name, 'rb')
  end
end


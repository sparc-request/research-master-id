require 'dotenv/tasks'

task update_pi_email: :environment do

  eirb_api =  ENV.fetch("EIRB_API")
  eirb_api_token = ENV.fetch("EIRB_API_TOKEN")
  eirb_studies = HTTParty.get("#{eirb_api}/studies.json?musc_studies=true",
                              timeout: 500, headers: {'Content-Type' => 'application/json',
                              "Authorization" => "Token token=\"#{eirb_api_token}\""})
  eirb_studies.each do |study|
    unless study['pi_name'].empty?
      protocol = Protocol.find_by(eirb_id: study['pro_number'])
      unless protocol.nil?
        pi = PrimaryPi.find_or_initialize_by(first_name: study['pi_name'].split(" ")[0], last_name: study['pi_name'].split(" ")[1], protocol: protocol)
        pi.update(email: study['pi_email'])
        pi.save
      end
    end
  end
end
require 'dotenv/tasks'

task update_pi_email: :environment do

  eirb_api =  ENV.fetch("EIRB_API")
  sparc_api = ENV.fetch("SPARC_API")

  def progress_bar(count, increment)
    bar = "Progress: "
    bar += "=" * (count/increment)
    bar += "#{count/increment}0%\r"
  end

  puts("\nBeginning data retrieval from APIs...")


  print("Fetching from SPARC_API... ")
  protocols = HTTParty.get("#{sparc_api}/protocols", timeout: 500, headers: {'Content-Type' => 'application/json'})
  puts("Done")

  puts("Total number of protocols from SPARC_API: #{protocols.count}")
  count = 1

  puts("\n\nBeginning SPARC_API data import...")
  protocols.each do |protocol|
    if Protocol.exists?(sparc_id: protocol['id'])
      record = Protocol.find_by(sparc_id: protocol['id'])
      pi = record.primary_pi
      unless pi.nil?
        unless protocol['email'].nil?
          pi.update_attribute(:email, protocol['email'])
        end
      end
    end
    print(progress_bar(count, protocols.count/10)) if count % (protocols.count/10)
    count += 1
  end

  eirb_api_token = ENV.fetch("EIRB_API_TOKEN")
  puts("Fetching from EIRB_API...")
  eirb_studies = HTTParty.get("#{eirb_api}/studies.json?musc_studies=true",
                              timeout: 500, headers: {'Content-Type' => 'application/json',
                              "Authorization" => "Token token=\"#{eirb_api_token}\""})

  puts("Done")
  puts("\n\nBeginning EIRB_API email import...")
  puts("Total number of protocols from EIRB_API: #{eirb_studies.count}")
  count = 1

  eirb_studies.each do |study|
    if Protocol.exists?(eirb_id: study['pro_number'])
      protocol = Protocol.find_by(eirb_id: study['pro_number'])
      unless protocol.nil?
        pi = protocol.primary_pi
        unless pi.nil?
          unless study['pi_email'].nil?
            pi.update_attribute(:email, study['pi_email'])
          end
        end
      end
    end
    print(progress_bar(count, eirb_studies.count/10)) if count % (eirb_studies.count/10)
    count += 1
  end
  puts "Done"
  puts("Finished API email update")
end

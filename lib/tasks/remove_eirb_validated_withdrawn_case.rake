task remove_eirb_validated_withdrawn_case: :environment do
  eirb_api = ENV.fetch('EIRB_API')
  eirb_api_token = ENV.fetch('EIRB_API_TOKEN')

  print("Fetching from EIRB_API... ")
  eirb_studies = HTTParty.get("#{eirb_api}/studies.json?musc_studies=true",
                              timeout: 500, headers: {'Content-Type' => 'application/json',
                              "Authorization" => "Token token=\"#{eirb_api_token}\""})

  puts("Done")

  puts("\n\nBeginning EIRB_API data update...")
  records_updated = []
  eirb_studies.each do |study|
    unless study['research_master_id'].nil?
      not_valid = ['Withdrawn']
      if ResearchMaster.exists?(study['research_master_id'])
        rm = ResearchMaster.find(study['research_master_id'])
        unless rm.nil?
          if not_valid.include?(study['state']) && rm.eirb_validated?
            rm.update_attribute(:eirb_validated, false)
            records_updated.append(rm) if rm.save
          end
        end
      end
    end
  end
  puts("#{records_updated.count} records updated")
end

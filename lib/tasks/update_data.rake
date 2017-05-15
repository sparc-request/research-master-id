require 'dotenv/tasks'

task update_data: :environment do

  def create_and_filter_eirb_study(study, new_protocols)
    eirb_study = Protocol.new(type: study['type'],
                                 short_title: study['short_title'] || "",
                                 long_title: study['title'] || "",
                                 eirb_id: study['pro_number'],
                                 eirb_institution_id: study['institution_id'],
                                 eirb_state: study['state']
                                )
    eirb_study.long_title.gsub!(/[^a-zA-Z0-9\-.\s%\/$*<>!@#^\[\]{};:"'?&()-_=+]/, ' ')
    eirb_study.short_title.gsub!(/[^a-zA-Z0-9\-.\s%\/$*<>!@#^\[\]{};:"'?&()-_=+]/, ' ')
    new_protocols.append(eirb_study.id) if eirb_study.save
    eirb_study
  end

  def progress_bar(count, increment)
    bar = "Progress: "
    bar += "=" * (count/increment)
    bar += "#{count/increment}0%\r"
  end

  save_errors = ""

  puts("\nBeginning data retrieval from APIs...")

  sparc_api = ENV.fetch("SPARC_API")
  eirb_api =  ENV.fetch("EIRB_API")
  eirb_api_token = ENV.fetch("EIRB_API_TOKEN")

  print("Fetching from SPARC_API... ")
  protocols = HTTParty.get("#{sparc_api}/protocols", timeout: 500, headers: {'Content-Type' => 'application/json'})
  puts("Done")

  print("Fetching from EIRB_API... ")
  eirb_studies = HTTParty.get("#{eirb_api}/studies.json?musc_studies=true",
                              timeout: 500, headers: {'Content-Type' => 'application/json',
                              "Authorization" => "Token token=\"#{eirb_api_token}\""})
  puts("Done")

  puts("\nError retrieving protocols from SPARC_API: #{protocols}") if protocols.is_a? String
  puts("\nError retrieving protocols from EIRB_API: #{eirb_studies}") if eirb_studies.is_a? String

  puts("\n\nBeginning SPARC_API data import...")
  puts("Total number of protocols from SPARC_API: #{protocols.count}")
  count = 1
  new_sparc_protocols = []
  new_sparc_pis = []
  protocols.each do |protocol|
    unless Protocol.exists?(sparc_id: protocol['id'])
      sparc_protocol = Protocol.new(type: protocol['type'],
                                       short_title: protocol['short_title'],
                                       long_title: protocol['title'],
                                       sparc_id: protocol['id'],
                                       sparc_pro_number: protocol['pro_number']
                                      )
      new_sparc_protocols.append(sparc_protocol.id) if sparc_protocol.save
      unless protocol['pi_name'].nil?
        pi = PrimaryPi.find_or_initialize_by(name: protocol['pi_name'],
                                            department: protocol['pi_department'].humanize.titleize,
                                            protocol: sparc_protocol)
        new_sparc_pis.append(pi.id) if pi.save
      end
    else
      existing_protocol = Protocol.find_by(sparc_id: protocol['id'])
      existing_protocol.update_attribute(:short_title, protocol['short_title'])
    end
    unless protocol['research_master_id'].nil?
      if ResearchMaster.exists?(protocol['research_master_id'])
        ar = AssociatedRecord.find_or_create_by(
          research_master_id: protocol['research_master_id']
        )
        ar.update_attribute(:sparc_id, Protocol.find_by(sparc_id: protocol['id']).id)
      end
    end
    print(progress_bar(count, protocols.count/10)) if count % (protocols.count/10)
    count += 1
  end
  puts("")
  puts("Done!")
  puts("New protocols total: #{new_sparc_protocols.count}")
  puts("New primary pis total: #{new_sparc_pis.count}")
  puts("Finished SPARC_API data import.")

  puts("\n\nBeginning EIRB_API data import...")
  puts("Total number of protocols from EIRB_API: #{eirb_studies.count}")
  count = 1
  new_eirb_protocols = []
  new_eirb_pis = []
  eirb_studies.each do |study|
    if Protocol.exists?(eirb_id: study['pro_number'])
      protocol = Protocol.find_by(eirb_id: study['pro_number'])
      protocol.update_attribute(:short_title, study['short_title'])
    elsif Protocol.exists?(eirb_id: study['pro_number'])
      if Protocol.find_by(eirb_id: study['pro_number']).type == 'SPARC'
        eirb_study = create_and_filter_eirb_study(study, new_eirb_protocols)
      end
      unless study['pi_name'].nil?
        pi = PrimaryPi.find_or_initialize_by(name: study['pi_name'], protocol: eirb_study)
        new_erib_pis.append(pi.id) if pi.save
      end
    else
      eirb_study = create_and_filter_eirb_study(study, new_eirb_protocols)
      unless study['pi_name'].nil?
        pi = PrimaryPi.find_or_initialize_by(name: study['pi_name'], protocol: eirb_study)
        new_eirb_pis.append(pi.id) if pi.save
      end
    end
    unless study['research_master_id'].nil?
      validated_states = ['Acknowledged', 'Approved', 'Completed', 'Disapproved', 'Exempt Approved', 'Expired',  'Expired - Continuation in Progress', 'External IRB Review Archive', 'Not Human Subjects Research', 'Suspended', 'Terminated', 'Withdrawn']
      if ResearchMaster.exists?(study['research_master_id'])
        ar = AssociatedRecord.find_or_create_by(
          research_master_id: study['research_master_id']
        )
        if Protocol.where(eirb_id: study['pro_number'], type: 'EIRB').present?
          ar.update_attribute(:eirb_id, Protocol.where(eirb_id: study['pro_number'], type: 'EIRB').first.id)
        end
        if validated_states.include?(study['state'])
          rm = ResearchMaster.find(study['research_master_id'])
          rm.update_attributes(short_title: study['short_title'], long_title: study['title'], eirb_validated: true)
        end
      end
    end
    print(progress_bar(count, eirb_studies.count/10)) if count % (eirb_studies.count/10)
    count += 1
  end
  puts("")
  puts("Done!")
  puts("New protocols total: #{new_eirb_protocols.count}")
  puts("New primary pis total: #{new_eirb_pis.count}")
  puts("Finished EIRB_API data import.")

  puts("New protocol ids: #{new_eirb_protocols + new_sparc_protocols}")
  puts("New primary pi ids: #{new_eirb_pis + new_sparc_pis}")
end

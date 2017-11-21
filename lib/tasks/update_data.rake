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
    new_protocols.append(eirb_study.id) if eirb_study.save
    eirb_study
  end

  def progress_bar(count, increment)
    bar = "Progress: "
    bar += "=" * (count/increment)
    bar += "#{count/increment}0%\r"
  end

  save_errors = ""

  ResearchMaster.all.each do |rm|
    rm.update_attribute(:eirb_validated, false)
    validated_states = ['Acknowledged', 'Approved', 'Completed', 'Disapproved', 'Exempt Approved', 'Expired',  'Expired - Continuation in Progress', 'External IRB Review Archive', 'Not Human Subjects Research', 'Suspended', 'Terminated']
    unless rm.eirb_protocol_id.nil?
      protocol = Protocol.find(rm.eirb_protocol_id)
      if validated_states.include?(protocol.eirb_state)
        rm.update_attribute(:eirb_validated, true)
        rm.update_attribute(:short_title, protocol.short_title)
        rm.update_attribute(:long_title, protocol.long_title)
      else
        rm.update_attribute(:eirb_validated, false)
      end
    end
  end
  puts("\nBeginning data retrieval from APIs...")

  sparc_api = ENV.fetch("SPARC_API")
  eirb_api =  ENV.fetch("EIRB_API")
  eirb_api_token = ENV.fetch("EIRB_API_TOKEN")
  coeus_api = ENV.fetch("COEUS_API")

  print("Fetching from SPARC_API... ")
  protocols = HTTParty.get("#{sparc_api}/protocols", timeout: 500, headers: {'Content-Type' => 'application/json'})
  puts("Done")

  print("Fetching from EIRB_API... ")
  eirb_studies = HTTParty.get("#{eirb_api}/studies.json?musc_studies=true",
                              timeout: 500, headers: {'Content-Type' => 'application/json',
                              "Authorization" => "Token token=\"#{eirb_api_token}\""})
  puts("Done")

  print("Fetching from COEUS_API... ")
  award_details = HTTParty.get("#{coeus_api}/award_details", timeout: 500, headers: {'Content-Type' => 'application/json'})
  awards_hrs = HTTParty.get("#{coeus_api}/awards_hrs", timeout: 500, headers: {'Content-Type' => 'application/json'})
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
      if protocol['first_name'] || protocol['last_name']
        pi = PrimaryPi.find_or_initialize_by(first_name: protocol['first_name'],
                                            last_name: protocol['last_name'],
                                            department: Department.find_or_create_by(name: protocol['pi_department'].nil? ? 'N/A' : protocol['pi_department']),
                                            protocol: sparc_protocol)
        new_sparc_pis.append(pi.id) if pi.save
      end
    else
      existing_protocol = Protocol.find_by(sparc_id: protocol['id'])
      existing_protocol.update_attribute(:short_title, protocol['short_title'])
    end
    unless protocol['research_master_id'].nil?
      rm = ResearchMaster.find_by(id: protocol['research_master_id'])
      unless rm.nil?
        rm.update_attributes(sparc_protocol_id: Protocol.find_by(sparc_id: protocol['id']).id)
        if rm.sparc_association_date.nil?
          rm.update_attribute(:sparc_association_date, DateTime.current)
        end
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
      protocol.update_attribute(:long_title, study['title'])
      protocol.update_attribute(:eirb_state, study['state'])
      protocol.update_attribute(:eirb_institution_id, study['institution_id'])
    #TODO How would this ever get called.  The `if` above would always catch this, right?
    elsif Protocol.exists?(eirb_id: study['pro_number'])
      if Protocol.find_by(eirb_id: study['pro_number']).type == 'SPARC'
        eirb_study = create_and_filter_eirb_study(study, new_eirb_protocols)
      end
      if study['first_name'] || study['last_name']
        pi = PrimaryPi.find_or_initialize_by(first_name: study['first_name'], last_name: study['last_name'], protocol: eirb_study)
        new_erib_pis.append(pi.id) if pi.save
      end
    else
      eirb_study = create_and_filter_eirb_study(study, new_eirb_protocols)
      if study['first_name'] || study['last_name']
        pi = PrimaryPi.find_or_initialize_by(
          first_name: study['first_name'],
          last_name: study['last_name'],
          department: Department.find_or_create_by(name: study['pi_department'].nil? ? 'N/A' : study['pi_department']),
          protocol: eirb_study
        )
        new_eirb_pis.append(pi.id) if pi.save
      end
    end
    unless study['research_master_id'].nil?
      validated_states = ['Acknowledged', 'Approved', 'Completed', 'Disapproved', 'Exempt Approved', 'Expired',  'Expired - Continuation in Progress', 'External IRB Review Archive', 'Not Human Subjects Research', 'Suspended', 'Terminated']
      rm = ResearchMaster.find_by(id: study['research_master_id'])
      unless rm.nil?
        if Protocol.where(eirb_id: study['pro_number'], type: 'EIRB').present?
          rm.update_attributes(eirb_protocol_id: Protocol.where(eirb_id: study['pro_number'], type: 'EIRB').first.id)
          if rm.eirb_association_date.nil?
            rm.update_attribute(:eirb_association_date, DateTime.current)
          end
        end
        if validated_states.include?(study['state'])
          rm.update_attributes(short_title: study['short_title'], long_title: study['title'], eirb_validated: true)
        end
      end
    end
    print(progress_bar(count, eirb_studies.count/10)) if count % (eirb_studies.count/10)
    count += 1
  end
  puts("Finished EIRB_API data import.")

  puts("\n\nBeginning COEUS API data import...")
  puts("Total number of protocols from COEUS API: #{award_details.count}")
  count = 1
  award_details.each do |ad|
    unless Protocol.exists?(mit_award_number: ad['mit_award_number'])
      Protocol.create(
        type: 'COEUS',
        mit_award_number: ad['mit_award_number'],
        sequence_number: ad['sequence_number'],
        title: ad['title'],
        entity_award_number: ad['entity_award_number']
      )
    end
    if ResearchMaster.exists?(ad['rmid'])
      ResearchMasterCoeusRelation.find_or_create_by(
        protocol: Protocol.find_by(mit_award_number: ad['mit_award_number']),
        research_master: ResearchMaster.find(ad['rmid'])
      )
    end
    print(progress_bar(count, award_details.count/10)) if count % (award_details.count/10)
    count += 1
  end
  puts("Updating protocols from COEUS API: #{awards_hrs.count}")
  count = 1
  awards_hrs.each do |ah|
    if Protocol.exists?(mit_award_number: ah['mit_award_number'])
      protocol = Protocol.find_by(mit_award_number: ah['mit_award_number'])
      protocol.update_attribute(:coeus_protocol_number, ah['protocol_number'])
    end
    print(progress_bar(count, awards_hrs.count/10)) if count % (awards_hrs.count/10)
  end


  puts("")
  puts("Done!")
  puts("Finished COEUS_API data import.")

  puts("New protocols total: #{new_eirb_protocols.count}")
  puts("New primary pis total: #{new_eirb_pis.count}")
  puts("New protocol ids: #{new_eirb_protocols + new_sparc_protocols}")
  puts("New primary pi ids: #{new_eirb_pis + new_sparc_pis}")
end

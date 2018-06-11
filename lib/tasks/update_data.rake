require 'dotenv/tasks'

task update_data: :environment do
  notifier = Slack::Notifier.new(ENV.fetch('SLACK_WEBHOOK_URL'))

  def create_and_filter_eirb_study(study, new_protocols)
    eirb_study = Protocol.new(type: study['type'],
                                 short_title: study['short_title'] || "",
                                 long_title: study['title'] || "",
                                 eirb_id: study['pro_number'],
                                 eirb_institution_id: study['institution_id'],
                                 eirb_state: study['state'],
                                 date_initially_approved: study['date_initially_approved'],
                                 date_approved: study['date_approved'],
                                 date_expiration: study['date_expiration']
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
  ResearchMaster.all.each do |rm|
    rm.update_attribute(:sparc_protocol_id, nil)
  end
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
      existing_protocol.update_attribute(:long_title, protocol['title'])
      unless existing_protocol.primary_pi.nil?
        existing_protocol.primary_pi.update_attribute(:first_name, protocol['first_name'])
        existing_protocol.primary_pi.update_attribute(:last_name, protocol['last_name'])
        existing_protocol.primary_pi.update_attribute(:department, Department.find_or_create_by(name: protocol['pi_department'].nil? ? 'N/A' : protocol['pi_department']))
      end
    end
    unless protocol['research_master_id'].nil?
      rm = ResearchMaster.find_by(id: protocol['research_master_id'])
      unless rm.nil?
        rm.update_attribute(:sparc_protocol_id, Protocol.find_by(sparc_id: protocol['id']).id)
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
  ResearchMaster.all.each do |rm|
    rm.update_attribute(:eirb_protocol_id, nil)
  end
  eirb_studies.each do |study|
    if Protocol.exists?(eirb_id: study['pro_number'])
      ################update eirb protocol####################
      protocol = Protocol.find_by(eirb_id: study['pro_number'])
      protocol.update_attribute(:short_title, study['short_title'])
      protocol.update_attribute(:long_title, study['title'])
      protocol.update_attribute(:eirb_state, study['state'])
      protocol.update_attribute(:eirb_institution_id, study['institution_id'])
      protocol.update_attribute(:date_initially_approved, study['date_initially_approved'])
      protocol.update_attribute(:date_approved, study['date_approved'])
      protocol.update_attribute(:date_expiration, study['date_expiration'])
      ###############update eirb protocol##########################

      ###############update eirb pi##############################
      pi = PrimaryPi.find_or_create_by(protocol_id: protocol.id)
      pi.update_attribute(:first_name, study['first_name'])
      pi.update_attribute(:last_name, study['last_name'])
      pi.update_attribute(:email, study['pi_email'])
      pi.update_attribute(:net_id, study['pi_net_id'])
      ###############update eirb pi###########################
    else
      #############new eirb protocols#######################
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
      ############new eirb protocols######################
    end
    unless study['research_master_id'].nil?
      validated_states = ['Acknowledged', 'Approved', 'Completed', 'Disapproved', 'Exempt Approved', 'Expired',  'Expired - Continuation in Progress', 'External IRB Review Archive', 'Not Human Subjects Research', 'Suspended', 'Terminated']
      rm = ResearchMaster.find_by(id: study['research_master_id'])
      unless rm.nil?
        if Protocol.where(eirb_id: study['pro_number'], type: 'EIRB').present?
          rm.update_attribute(:eirb_protocol_id, Protocol.where(eirb_id: study['pro_number'], type: 'EIRB').first.id)
          if rm.eirb_association_date.nil?
            rm.update_attribute(:eirb_association_date, DateTime.current)
          end
        end
        if validated_states.include?(study['state'])
          rm.update_attribute(:short_title, study['short_title'])
          rm.update_attribute(:long_title, study['title'])
          rm.update_attribute(:eirb_validated, true)
          friendly_token = Devise.friendly_token
          pi = User.find_or_create_by(net_id: study['pi_net_id'].remove('@musc.edu')) do |user|
            user.email = study['pi_email']
            user.name = "#{study['first_name']} #{study['last_name']}"
            user.password = friendly_token
            user.password_confirmation = friendly_token
          end
          existing_pi = rm.pi

          # update pi only if the pi record is valid
          if pi.valid?
            rm.pi_id = pi.id

            if rm.pi_id_changed? && rm.pi_id.present?
              rm.save(validate: false)
              unless existing_pi.nil?
                begin
                  PiMailer.notify_pis(rm, existing_pi, rm.pi, rm.creator).deliver_now
                rescue
                  if ENV.fetch('ENVIRONMENT') == 'production'
                    notifier.ping "PI email failed to deliver"
                    notifier.ping "#{pi.inspect}"
                    notifier.ping "#{pi.errors.full_messages}"
                  end
                end
              end
            end
          else
            if ENV.fetch('ENVIRONMENT') == 'production'
              notifier.ping "PI record failed to update Research Master record"
              notifier.ping "#{pi.inspect}"
              notifier.ping "#{pi.errors.full_messages}"
            end
          end
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
      ResearchMasterCoeusRelation.find_or_create_by(protocol: Protocol.find_by(mit_award_number: ad['mit_award_number'])) do |rmcr|
        rmcr.research_master_id = ad['rmid']
      end
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

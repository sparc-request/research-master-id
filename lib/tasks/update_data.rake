require 'dotenv/tasks'

task update_data: :environment do
  begin
    script_start      = Time.now

    $status_notifier   = Slack::Notifier.new(ENV.fetch('CRONJOB_STATUS_WEBHOOK'))
    $error_notifier    = Slack::Notifier.new(ENV.fetch('SLACK_WEBHOOK_URL'))

    $status_notifier.ping "Cronjob has started."

    $validated_states  = ['Acknowledged', 'Approved', 'Completed', 'Disapproved', 'Exempt Approved', 'Expired',  'Expired - Continuation in Progress', 'External IRB Review Archive', 'Not Human Subjects Research', 'Suspended', 'Terminated']
    $friendly_token    = Devise.friendly_token
    $research_masters  = ResearchMaster.eager_load(:pi).all
    $rmc_relations     = ResearchMasterCoeusRelation.all
    $departments       = Department.all
    $users             = User.all

    def progress_bar(count, increment)
      bar = "Progress: |"
      bar += ("=" * (count/increment)).ljust(10)
      bar += "| #{count/increment*10}%\r"
    end

    def find_or_create_department(pi_department)
      name = pi_department || 'N/A'
      dept = nil

      unless dept = $departments.detect{ |d| d.name == name }
        dept = Department.create(
          name: name
        )
      end

      dept
    end

    def update_eirb_study_pi(rm, first_name, last_name, email, net_id)
      net_id.slice!('@musc.edu')
      
      pi = nil

      unless pi = $users.detect{ |u| u.net_id == net_id }
        pi = User.create(
          email:                  email,
          net_id:                 net_id,
          name:                   "#{first_name} #{last_name}",
          password:               $friendly_token,
          password_confirmation:  $friendly_token
        )
      end

      if pi.valid?
        existing_pi = rm.pi
        rm.pi_id    = pi.id

        if rm.pi_id && rm.pi_id_changed? && existing_pi
          begin
            PiMailer.notify_pis(rm, existing_pi, rm.pi, rm.creator).deliver_now
          rescue
            if ENV.fetch('ENVIRONMENT') == 'production'
              $error_notifier.ping "PI email failed to deliver"
              $error_notifier.ping "#{pi.inspect}"
              $error_notifier.ping "#{pi.errors.full_messages}"
            end
          end
        end
      elsif ENV.fetch('ENVIRONMENT') == 'production'
        $error_notifier.ping "PI record failed to update Research Master record"
        $error_notifier.ping "#{pi.inspect}"
        $error_notifier.ping "#{pi.errors.full_messages}"
      end
    end

    puts("\nBeginning data retrieval from APIs...")

    sparc_api       = ENV.fetch("SPARC_API")
    eirb_api        = ENV.fetch("EIRB_API")
    eirb_api_token  = ENV.fetch("EIRB_API_TOKEN")
    coeus_api       = ENV.fetch("COEUS_API")

    print "Fetching from SPARC_API... "

    start     = Time.now
    protocols = HTTParty.get("#{sparc_api}/protocols", timeout: 500, headers: {'Content-Type' => 'application/json'})
    finish    = Time.now

    print "Done (#{(finish - start).to_i} Seconds)\n"

    print "Fetching from EIRB_API..."

    start         = Time.now
    eirb_studies  = HTTParty.get("#{eirb_api}/studies.json?musc_studies=true", timeout: 500, headers: {'Content-Type' => 'application/json', "Authorization" => "Token token=\"#{eirb_api_token}\""})
    finish        = Time.now

    print "Done (#{(finish - start).to_i} Seconds)\n"

    print "Fetching from COEUS_API... "

    start         = Time.now
    award_details = HTTParty.get("#{coeus_api}/award_details", timeout: 500, headers: {'Content-Type' => 'application/json'})
    awards_hrs    = HTTParty.get("#{coeus_api}/awards_hrs", timeout: 500, headers: {'Content-Type' => 'application/json'})
    prism_users   = HTTParty.get("#{coeus_api}/prism", timeout: 500, headers: {'Content-Type' => 'application/json'})
    finish        = Time.now

    print "Done (#{(finish - start).to_i} Seconds)\n"

    puts("\nError retrieving protocols from SPARC_API: #{protocols}")   if protocols.is_a?(String)
    puts("\nError retrieving protocols from EIRB_API: #{eirb_studies}") if eirb_studies.is_a?(String)

    unless protocols.is_a?(String)
      ResearchMaster.update_all(sparc_protocol_id: nil)

      puts("\n\nBeginning SPARC_API data import...")
      puts("Total number of protocols from SPARC_API: #{protocols.count}")

      start                   = Time.now
      count                   = 1
      created_sparc_protocols = []
      created_sparc_pis       = []

      # Preload SPARC Protocols to improve efficiency
      sparc_protocols           = Protocol.eager_load(:primary_pi).where(type: 'SPARC')
      existing_sparc_ids        = sparc_protocols.pluck(:sparc_id)
      existing_sparc_protocols  = protocols.select{ |p| existing_sparc_ids.include?(p['id']) }
      new_sparc_protocols       = protocols.select{ |p| existing_sparc_ids.exclude?(p['id']) }

      # Update Existing SPARC Protocol Records
      existing_sparc_protocols.each do |protocol|
        existing_protocol = sparc_protocols.detect{ |p| p.sparc_id == protocol['id'] }

        existing_protocol.short_title = protocol['short_title']
        existing_protocol.long_title  = protocol['title']

        existing_protocol.save(validate: false)

        if existing_protocol.primary_pi
          existing_protocol.primary_pi.first_name = protocol['first_name']
          existing_protocol.primary_pi.last_name  = protocol['last_name']
          existing_protocol.primary_pi.department = find_or_create_department(protocol['pi_department'])

          existing_protocol.primary_pi.save(validate: false)
        end

        if protocol['research_master_id'] && rm = $research_masters.detect{ |rm| rm.id == protocol['research_master_id'] }
          rm.sparc_protocol_id      = existing_protocol.id
          rm.sparc_association_date = DateTime.current unless rm.sparc_association_date

          rm.save(validate: false)
        end

        print progress_bar(count, protocols.count/10) if count % (protocols.count/10)
        count += 1
      end

      # Create New SPARC Protocol Records
      new_sparc_protocols.each do |protocol|
        sparc_protocol = Protocol.new(
          type:             protocol['type'],
          short_title:      protocol['short_title'],
          long_title:       protocol['title'],
          sparc_id:         protocol['id'],
          sparc_pro_number: protocol['pro_number']
        )

        created_sparc_protocols.append(sparc_protocol.id) if sparc_protocol.save

        if protocol['first_name'] || protocol['last_name']
          pi = PrimaryPi.new(
            first_name: protocol['first_name'],
            last_name:  protocol['last_name'],
            department: find_or_create_department(protocol['pi_department']),
            protocol:   sparc_protocol
          )

          created_sparc_pis.append(pi.id) if pi.save
        end

        if protocol['research_master_id'] && rm = $research_masters.detect{ |rm| rm.id == protocol['research_master_id'] }
          rm.sparc_protocol_id      = sparc_protocol.id
          rm.sparc_association_date = DateTime.current unless rm.sparc_association_date

          rm.save(validate: false)
        end

        print progress_bar(count, protocols.count/10) if count % (protocols.count/10)
        count += 1
      end

      finish = Time.now

      puts("\nDone!")
      puts("\nNew protocols total: #{created_sparc_protocols.count}")
      puts("New primary pis total: #{created_sparc_pis.count}")
      puts("Finished SPARC_API data import (#{(finish - start).to_i} Seconds).")
    end

    unless eirb_studies.is_a?(String)
      ResearchMaster.update_all(eirb_validated: false)

      puts("\n\nBeginning EIRB_API data import...")
      puts("Total number of protocols from EIRB_API: #{eirb_studies.count}")

      start                   = Time.now
      count                   = 1
      created_eirb_protocols  = []
      created_eirb_pis        = []

      ResearchMaster.update_all(eirb_protocol_id: nil)

      # Preload eIRB Protocols to improve efficiency
      eirb_protocols        = Protocol.eager_load(:primary_pi).where(type: 'EIRB')
      existing_eirb_ids     = eirb_protocols.pluck(:eirb_id)
      existing_eirb_studies = eirb_studies.select{ |s| existing_eirb_ids.include?(s['pro_number']) }
      new_eirb_studies      = eirb_studies.select{ |s| existing_eirb_ids.exclude?(s['pro_number']) }

      # Update Existing eIRB Protocol Records
      existing_eirb_studies.each do |study|
        existing_protocol                         = eirb_protocols.detect{ |p| p.eirb_id == study['pro_number'] }
        existing_protocol.short_title             = study['short_title']
        existing_protocol.long_title              = study['title']
        existing_protocol.eirb_state              = study['state']
        existing_protocol.eirb_institution_id     = study['institution_id']
        existing_protocol.date_initially_approved = study['date_initially_approved']
        existing_protocol.date_approved           = study['date_approved']
        existing_protocol.date_expiration         = study['date_expiration']

        existing_protocol.save(validate: false)

        if existing_protocol.eirb_state == 'Completed' && existing_protocol.primary_pi
          existing_protocol.primary_pi.first_name = study['first_name']
          existing_protocol.primary_pi.last_name  = study['last_name']
          existing_protocol.primary_pi.email      = study['pi_email']
          existing_protocol.primary_pi.net_id     = study['pi_net_id']
          existing_protocol.primary_pi.department = find_or_create_department(study['pi_department'])

          existing_protocol.primary_pi.save(validate: false)
        end

        if study['research_master_id'] && rm = $research_masters.detect{ |rm| rm.id == study['research_master_id'] }
          rm.eirb_protocol_id       = existing_protocol.id
          rm.eirb_association_date  = DateTime.current unless rm.sparc_association_date 

          if validated_states.include?(study['state'])
            rm.eirb_validated = true
            rm.short_tile     = study['short_title']
            rm.long_title     = study['title']

            update_eirb_study_pi(rm, study['first_name'], study['last_name'], study['email'], study['pi_net_id'], users)
          end

          rm.save(validate: false)
        end

        print progress_bar(count, eirb_studies.count/10) if count % (eirb_studies.count/10)
        count += 1
      end

      # Create New eIRB Protocol Records
      new_eirb_studies.each do |study|
        eirb_protocol = Protocol.new(
          type:                     study['type'],
          short_title:              study['short_title'] || "",
          long_title:               study['title'] || "",
          eirb_id:                  study['pro_number'],
          eirb_institution_id:      study['institution_id'],
          eirb_state:               study['state'],
          date_initially_approved:  study['date_initially_approved'],
          date_approved:            study['date_approved'],
          date_expiration:          study['date_expiration']
        )

        created_eirb_protocols.append(eirb_protocol.id) if eirb_protocol.save

        if study['first_name'] || study['last_name']
          pi = PrimaryPi.new(
            first_name: study['first_name'],
            last_name:  study['last_name'],
            department: find_or_create_department(study['pi_department']),
            protocol:   eirb_protocol
          )

          created_eirb_pis.append(pi.id) if pi.save
        end

        if study['research_master_id'] && rm = $research_masters.detect{ |rm| rm.id == study['research_master_id'] }
          rm.eirb_protocol_id       = eirb_protocol.id
          rm.eirb_association_date  = DateTime.current unless rm.sparc_association_date 

          if validated_states.include?(study['state'])
            rm.eirb_validated = true
            rm.short_tile     = study['short_title']
            rm.long_title     = study['title']

            update_eirb_study_pi(rm, study['first_name'], study['last_name'], study['email'], study['pi_net_id'], users)
          end

          rm.save(validate: false)
        end

        print progress_bar(count, eirb_studies.count/10) if count % (eirb_studies.count/10)
        count += 1
      end

      finish = Time.now

      puts("\nDone!")
      puts("\nNew protocols total: #{created_sparc_protocols.count}")
      puts("New primary pis total: #{created_sparc_pis.count}")
      puts("Finished EIRB_API data import (#{(finish - start).to_i} Seconds).")
    end

    puts("\n\nBeginning COEUS API data import...")
    puts("Total number of protocols from COEUS API: #{award_details.count}")
    
    start                   = Time.now
    count                   = 1
    created_coeus_protocols = []

    # Preload eIRB Protocols to improve efficiency
    coeus_protocols               = Protocol.where(type: 'COEUS')
    existing_award_numbers        = eirb_protocols.pluck(:mit_award_number)
    existing_coeus_award_details  = award_details.select{ |ad| existing_award_numbers.include?(ad['mit_award_number']) }
    new_coeus_award_details       = award_details.select{ |ad| existing_award_numbers.exclude?(ad['mit_award_number']) }

    # Update Existing COEUS Protocol Records
    existing_coeus_award_details.each do |ad|
      existing_protocol = coeus_protocols.detect{ |p| p.mit_award_number == ad['mit_award_number'] }

      if ad['rmid'] && rm = $research_masters.detect{ |rm| rm.id == ad['rmid'] }
        unless $rmc_relations.any?{ |rmcr| rmcr.protocol_id == existing_protocol.id && rmcr.research_master_id == rm.id }
          ResearchMasterCoeusRelation.create(
            protocol:         coeus_protocol,
            research_master:  rm
          )
        end
      end

      print progress_bar(count, (award_details.count + awards_hrs.count)/10) if count % (award_details.count/10)
      count += 1
    end

    # Create New COEUS Protocol Records
    new_coeus_award_details.each do |ad|
      coeus_protocol = Protocol.new(
        type:                 'COEUS',
        title:                ad['title'],
        mit_award_number:     ad['mit_award_number'],
        sequence_number:      ad['sequence_number'],
        entity_award_number:  ad['entity_award_number'],
        coeus_project_id:     ad['coeus_project_id']
      )

      created_coeus_protocols.append(coeus_protocol.id) if coeus_protocol.save

      if ad['rmid'] && rm = $research_masters.detect{ |rm| rm.id == ad['rmid'] }
        ResearchMasterCoeusRelation.create(
          protocol:         coeus_protocol,
          research_master:  rm
        )
      end

      print progress_bar(count, (award_details.count + awards_hrs.count)/10) if count % (award_details.count/10)
      count += 1
    end

    puts("Updating award numbers from COEUS API: #{awards_hrs.count}")

    count = 1

    existing_coeus_awards_hrs = awards_hrs.select{ |ah| existing_award_numbers.include?(ah['mit_award_number']) }
    new_coeus_awards_hrs      = awards_hrs.select{ |ah| existing_award_numbers.exclude?(ah['mit_award_number']) }

    existing_coeus_awards_hrs.each do |ah|
      existing_protocol                       = coeus_protocols.detect{ |p| p.mit_award_number == ah['mit_award_number'] }
      existing_protocol.coeus_protocol_number = ah['protocol_number']

      existing_protocol.save(validate: false)

      print progress_bar(count, (award_details.count + awards_hrs.count)/10) if count % (award_details.count/10)
      count += 1
    end

    new_coeus_awards_hrs.each do |ah|
      print progress_bar(count, (award_details.count + awards_hrs.count)/10) if count % (award_details.count/10)
      count += 1
    end

    puts("Updating users from COEUS API: #{prism_users.count}")

    count = 1
    
    prism_users.each do |user|
      if User.exists?(net_id: user['netid'])
        user_to_update = User.find_by(net_id: user['netid'])
        user_to_update.update_attribute(:department_id, Department.find_or_create_by(name: user['department']).id)
      end
      print(progress_bar(count, prism_users.count/10)) if count % (prism_users.count/10)
      count += 1
    end

    finish = Time.now

    puts("\nDone!")
    puts("\nNew protocols total: #{created_coeus_protocols.count}")
    puts("Finished COEUS_API data import (#{(finish - start).to_i} Seconds).")

    total_protocols = created_sparc_protocols + created_eirb_protocols + created_coeus_protocols
    total_pis       = created_sparc_pis + created_eirb_pis

    puts("\n\nNew protocols total: #{total_protocols.count}")
    puts("New primary pis total: #{total_pis.count}")
    puts("New protocol ids: #{total_protocols}")
    puts("New primary pi ids: #{total_pis}")

    script_finish = Time.now

    puts("\nScript Duration: #{(script_finish - script_start).to_i} Seconds.")

    $status_notifier.ping "Cronjob has completed successfully."
    $status_notifier.ping "Duration: #{(script_finish - script_start).to_i} Seconds"
  rescue => error
    puts error.inspect

    $error_notifier.ping "Cronjob has failed unexpectedly."
    $error_notifier.ping error.inspect
  end
end
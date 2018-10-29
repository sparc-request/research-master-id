require 'dotenv/tasks'

task update_from_sparc: :environment do
  begin
    ## turn off auditing for the duration of this script
    Protocol.auditing_enabled = false
    ResearchMaster.auditing_enabled = false
    User.auditing_enabled = false

    script_start      = Time.now

    $status_notifier   = Slack::Notifier.new(ENV.fetch('CRONJOB_STATUS_WEBHOOK'))

    $validated_states  = ['Acknowledged', 'Approved', 'Completed', 'Disapproved', 'Exempt Approved', 'Expired',  'Expired - Continuation in Progress', 'External IRB Review Archive', 'Not Human Subjects Research', 'Suspended', 'Terminated']
    $friendly_token    = Devise.friendly_token
    $research_masters  = ResearchMaster.eager_load(:pi).all
    $rmc_relations     = ResearchMasterCoeusRelation.all
    $departments       = Department.all
    $users             = User.all

    def log message
      puts "#{message}\n"
      $status_notifier.ping message
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

    log "*Cronjob (SPARC) has started.*"

    log "- *Beginning data retrieval from APIs...*"

    sparc_api       = ENV.fetch("SPARC_API")

    log "--- *Fetching from SPARC_API...*"

    start     = Time.now
    protocols = HTTParty.get("#{sparc_api}/protocols", timeout: 500, headers: {'Content-Type' => 'application/json'})
    finish    = Time.now

    if protocols.is_a?(String)
      log "----- :heavy_check_mark: *Done!* (#{(finish - start).to_i} Seconds)"
    else
      log "----- :heavy_exclamation_mark: Error retrieving protocols from SPARC_API: #{protocols}"
    end

    unless protocols.is_a?(String)
      ResearchMaster.update_all(sparc_protocol_id: nil)

      log "- *Beginning SPARC_API data import...*"
      log "--- Total number of protocols from SPARC_API: #{protocols.count}"

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
      log "--- Updating existing SPARC protocols"
      bar = ProgressBar.new(existing_sparc_protocols.count)

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

        bar.increment! rescue nil
      end

      # Create New SPARC Protocol Records
      log "--- Creating new SPARC protocols"
      bar = ProgressBar.new(new_sparc_protocols.count)

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

        bar.increment! rescue nil
      end

      finish = Time.now

      log "--- :heavy_check_mark: *Done!*"
      log "--- *New protocols total:* #{created_sparc_protocols.count}"
      log "--- *New primary pis total:* #{created_sparc_pis.count}"
      log "--- *New primary pi ids:* #{created_sparc_pis}"
      log "--- *Finished SPARC_API data import* (#{(finish - start).to_i} Seconds)."
    end

    script_finish = Time.now

    log "- *Script Duration:* #{(script_finish - script_start).to_i} Seconds."

    log ":heavy_check_mark: *Cronjob (SPARC) has completed successfully.*"

    ## turn on auditing
    Protocol.auditing_enabled = true
    ResearchMaster.auditing_enabled = true
    User.auditing_enabled = true
  rescue => error
    Protocol.auditing_enabled = true
    ResearchMaster.auditing_enabled = true
    User.auditing_enabled = true

    log ":heavy_exclamation_mark: *Cronjob (SPARC) has failed unexpectedly.*"
    log error.inspect
  end
end

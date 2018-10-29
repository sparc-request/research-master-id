require 'dotenv/tasks'

task update_from_eirb: :environment do
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
              log "PI email failed to deliver"
              log "#{pi.inspect}"
              log "#{pi.errors.full_messages}"
            end
          end
        end
      elsif ENV.fetch('ENVIRONMENT') == 'production'
        log ":heavy_exclamation_mark: PI record failed to update Research Master record"
        log "- #{pi.inspect}"
        log "- #{pi.errors.full_messages}"
      end
    end

    log "*Cronjob (EIRB) has started.*"

    log "- *Beginning data retrieval from APIs...*"

    eirb_api        = ENV.fetch("EIRB_API")
    eirb_api_token  = ENV.fetch("EIRB_API_TOKEN")

    log "--- *Fetching from EIRB_API...*"

    start         = Time.now
    eirb_studies  = HTTParty.get("#{eirb_api}/studies.json?musc_studies=true", timeout: 500, headers: {'Content-Type' => 'application/json', "Authorization" => "Token token=\"#{eirb_api_token}\""})
    finish        = Time.now

    if eirb_studies.is_a?(String)
      log "----- :heavy_exclamation_mark: Error retrieving protocols from EIRB_API: #{eirb_studies}"
    else
      log "----- :heavy_check_mark: *Done!* (#{(finish - start).to_i} Seconds)"

      ResearchMaster.update_all(eirb_validated: false)

      log "- *Beginning EIRB_API data import...*"
      log "--- Total number of protocols from EIRB_API: #{eirb_studies.count}"

      start                   = Time.now
      created_eirb_protocols  = []
      created_eirb_pis        = []

      ResearchMaster.update_all(eirb_protocol_id: nil)

      # Preload eIRB Protocols to improve efficiency
      eirb_protocols        = Protocol.eager_load(:primary_pi).where(type: 'EIRB')
      existing_eirb_ids     = eirb_protocols.pluck(:eirb_id)
      existing_eirb_studies = eirb_studies.select{ |s| existing_eirb_ids.include?(s['pro_number']) }
      new_eirb_studies      = eirb_studies.select{ |s| existing_eirb_ids.exclude?(s['pro_number']) }

      # Update Existing eIRB Protocol Records
      log "--- Updating existing eIRB protocols"
      bar = ProgressBar.new(existing_eirb_studies.count)

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

        if existing_protocol.eirb_state != 'Completed' && existing_protocol.primary_pi
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

        bar.increment! rescue nil
      end

      # Create New eIRB Protocol Records
      log "--- Creating new eIRB protocols"
      bar = ProgressBar.new(new_eirb_studies.count)

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

        bar.increment! rescue nil
      end

      finish = Time.now

      log "--- :heavy_check_mark: *Done!*"
      log "--- *New protocols total:* #{created_eirb_protocols.count}"
      log "--- *New primary pis total:* #{created_eirb_pis.count}"
      log "--- *New primary pi ids:* #{created_eirb_pis}"
      log "--- *Finished EIRB_API data import* (#{(finish - start).to_i} Seconds)."
    end

    script_finish = Time.now

    log "- *Script Duration:* #{(script_finish - script_start).to_i} Seconds."

    log ":heavy_check_mark: *Cronjob (EIRB) has completed successfully.*"

    ## turn on auditing
    Protocol.auditing_enabled = true
    ResearchMaster.auditing_enabled = true
    User.auditing_enabled = true
  rescue => error
    Protocol.auditing_enabled = true
    ResearchMaster.auditing_enabled = true
    User.auditing_enabled = true

    log ":heavy_exclamation_mark: *Cronjob (EIRB) has failed unexpectedly.*"
    log error.inspect
  end
end

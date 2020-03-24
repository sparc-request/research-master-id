require 'dotenv/tasks'

task update_from_cayuse: :environment do
  begin
    ## turn off auditing for the duration of this script
    Protocol.auditing_enabled = false
    ResearchMaster.auditing_enabled = false

    script_start      = Time.now
    # $status_notifier   = Slack::Notifier.new(ENV.fetch('CRONJOB_STATUS_WEBHOOK'))
    $friendly_token    = Devise.friendly_token

    ##Load up Research Masters ahead of time
    $research_masters  = ResearchMaster.all
    $rmc_relations     = ResearchMasterCayuseRelation.all

    def log message
      puts "#{message}\n"
      # $status_notifier.ping message
    end

    log "*Cronjob (CAYUSE) has started.*"
    log "- *Beginning data retrieval from APIs...*"
    log "--- *Fetching from CAYUSE_API...*"

    cayuse_api            = ENV.fetch("COEUS_API")
    start                 = Time.now
    projects_with_pi_list = HTTParty.get("#{cayuse_api}/cayuse_projects_with_pi_list", timeout: 500, headers: {'Content-Type' => 'application/json'})

    finish                = Time.now

    log "----- :heavy_check_mark: *Done!* (#{(finish - start).to_i} Seconds)"

    log "- *Beginning CAYUSE API data import...*"
    log "--- Total number of protocols from CAYUSE API: #{projects_with_pi_list.count}"


    start                    = Time.now
    created_cayuse_protocols = []

    # Preload CAYUSE Protocols to improve efficiency
    existing_cayuse_protocols  = Protocol.where(type: 'CAYUSE')
    existing_project_numbers   = existing_cayuse_protocols.pluck(:cayuse_project_number)


    # Create arrays for existing, and new protocols, based on cayuse_project_number
    already_imported_protocols = []
    need_imported              = []

    projects_with_pi_list.each do |project_with_pi_list|
      project = project_with_pi_list['project']

      if existing_project_numbers.include?(project['PROJECT_NUMBER'])
        already_imported_protocols << project_with_pi_list
      else
        need_imported << project_with_pi_list
      end
    end

    ## Update existing cayuse protocols (and link them if needed)
    log "--- Updating (or linking) existing CAYUSE protocols"
    bar = ProgressBar.new(already_imported_protocols.count)

    already_imported_protocols.each do |project_with_pi_list|
      project = project_with_pi_list['project']
      pi_list = project_with_pi_list['pi_list']
      existing_protocol = existing_cayuse_protocols.detect{|protocol| protocol.cayuse_project_number == project['PROJECT_NUMBER'] }

      #Update both fields that come from cayuse (that could change), just to make sure we catch any changes.
      existing_protocol.update_attributes(title: project['PROJECT_TITLE'], cayuse_pi_name: pi_list.join(", "))

      #Link any that might have been imported but not linked (do to timing of RMID vs cayuse creation)
      if research_master = $research_masters.detect{ |rm| rm.id == project['RMID'] }
        # But obviously don't if it already exists
        unless $rmc_relations.any?{ |rmcr| rmcr.protocol_id == existing_protocol.id && rmcr.research_master_id == research_master.id }
          ResearchMasterCayuseRelation.create(
            protocol:         existing_protocol,
            research_master:  research_master
          )
        end
      end

      bar.increment! rescue nil
    end
    log "--- :heavy_check_mark: *Done!*"

    # Create new cayuse protocols
    log "--- Creating new CAYUSE protocols"
    bar = ProgressBar.new(need_imported.count)

    need_imported.each do |project_with_pi_list|
      project = project_with_pi_list['project']
      pi_list = project_with_pi_list['pi_list']

      cayuse_protocol = Protocol.new(
        type:                   'CAYUSE',
        title:                  project['PROJECT_TITLE'],
        cayuse_project_number:  project['PROJECT_NUMBER'],
        cayuse_pi_name:         pi_list.join(", ")
      )

      if cayuse_protocol.save
        created_cayuse_protocols.append(cayuse_protocol.id)

        if research_master = $research_masters.detect{ |rm| rm.id == project['RMID'] }
          ResearchMasterCayuseRelation.create(
            protocol: cayuse_protocol,
            research_master: research_master
          )
        end
      end

      bar.increment! rescue nil
    end

    log "--- :heavy_check_mark: *Done!*"

    finish = Time.now

    log "--- :heavy_check_mark: *Done!*"
    log "--- *New protocols total:* #{created_cayuse_protocols.count}"
    log "--- *New protocol ids:* #{created_cayuse_protocols}"
    log "--- *Finished CAYUSE_API data import* (#{(finish - start).to_i} Seconds)."

    script_finish = Time.now

    log "- *Script Duration:* #{(script_finish - script_start).to_i} Seconds."
    log ":heavy_check_mark: *Cronjob (CAYUSE) has completed successfully.*"




    ## turn on auditing
    Protocol.auditing_enabled = true
    ResearchMaster.auditing_enabled = false
  rescue => error
    Protocol.auditing_enabled = true
    ResearchMaster.auditing_enabled = false

    log ":heavy_exclamation_mark: *Cronjob (CAYUSE) has failed unexpectedly.*"
    log error.inspect
  end
end

require 'dotenv/tasks' 

task updat_from_eirb_db: :environment do
  begin
    Protocol.auditing_enabled = false
    ResearchMaster.auditing_enabled = false
    User.auditing_enabled = false

    script_start = Time.now

    $status_notifier = Slack::Notifier.new(ENV.fetch('CRON_JOB_STATUS_WEBHOOK'))

    $validated_states = ['Acknowledged', 'Approved', 'Completed', 'Disapproved', 'Exempt Approved', 'Expired', 'Expired - Continuation in Progress', 'External IRB Review Archive', 'Not Human Subjects Research', 'Suspended', 'Terminated']

    $friendly_token = Devise.friendly_token

    $research_masters = ResearchMaster.eager_load(:pi).all

    $users = User.all

    def log message
      puts "#{message}\n"
      $status_notifier.ping message
    end

    log "*Cronjob (EIRB) has started.*"

    log "--- *Connecting to EIRB Database...*"

    begin
      eirb_db = EirbConnection.connection # check if connection is valid
      valid_connection = true

    rescue
      log "---- :heavy_exclamation_mark: Cannot connect to EIRB Database"
    end

    if valid_connection
      log "- *Beginning data retrieval from EIRB Database...*"

      start = Time.now

      # eirb_studies = HTTParty.get("#{eirb_api}/studies.json?musc_studies=true", timeout: 500, headers: {'Content-Type' => 'application/json', "Authorization" => "Token token=\"#{eirb_api_token}\""})
      eirb_studies = EirbStudy.is_musc.filter_out_preserve_state.filter_invalid_pro_numbers

      finish = Time.now

      log "----- :heavy_check_mark: *Done!* (#{(finish - start).to_i} Seconds)"


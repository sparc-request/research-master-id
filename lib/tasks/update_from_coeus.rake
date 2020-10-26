# Copyright © 2020 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

require 'dotenv/tasks'

task update_from_coeus: :environment do
  begin
    ## turn off auditing for the duration of this script
    Protocol.auditing_enabled = false
    ResearchMaster.auditing_enabled = false
    User.auditing_enabled = false

    script_start      = Time.now

    $status_notifier   = Slack::Notifier.new(ENV.fetch('CRONJOB_STATUS_WEBHOOK'))

    $friendly_token    = Devise.friendly_token
    $research_masters  = ResearchMaster.eager_load(:pi).all
    $rmc_relations     = ResearchMasterCoeusRelation.all
    $users             = User.all

    def log message
      puts "#{message}\n"
      $status_notifier.ping message
    end

    log "*Cronjob (COEUS) has started.*"

    log "- *Beginning data retrieval from APIs...*"

    coeus_api       = ENV.fetch("COEUS_API")

    log "--- *Fetching from COEUS_API...*"

    start         = Time.now
    award_details = HTTParty.get("#{coeus_api}/award_details", timeout: 500, headers: {'Content-Type' => 'application/json'})
    awards_hrs    = HTTParty.get("#{coeus_api}/awards_hrs", timeout: 500, headers: {'Content-Type' => 'application/json'})
    prism_users   = HTTParty.get("#{coeus_api}/prism", timeout: 500, headers: {'Content-Type' => 'application/json'})
    finish        = Time.now

    log "----- :heavy_check_mark: *Done!* (#{(finish - start).to_i} Seconds)"

    log "- *Beginning COEUS API data import...*"
    log "--- Total number of protocols from COEUS API: #{award_details.count}"

    start                   = Time.now
    created_coeus_protocols = []

    # Preload COEUS Protocols to improve efficiency
    coeus_protocols               = Protocol.where(type: 'COEUS')
    existing_award_numbers        = coeus_protocols.pluck(:mit_award_number)
    existing_coeus_award_details  = award_details.select{ |ad| existing_award_numbers.include?(ad['mit_award_number']) }
    new_coeus_award_details       = award_details.select{ |ad| existing_award_numbers.exclude?(ad['mit_award_number']) }

    # Update Existing COEUS Protocol Records
    log "--- Updating existing COEUS protocols"
    bar = ProgressBar.new(existing_coeus_award_details.count)

    existing_coeus_award_details.each do |ad|
      existing_protocol = coeus_protocols.detect{ |p| p.mit_award_number == ad['mit_award_number'] }
      existing_protocol.update_attributes(coeus_project_id: ad['coeus_project_id'])

      if ad['rmid'].present? && rm = $research_masters.detect{ |rm| rm.id == ad['rmid'] }
        unless $rmc_relations.any?{ |rmcr| rmcr.protocol_id == existing_protocol.id && rmcr.research_master_id == rm.id }
          ResearchMasterCoeusRelation.create(
            protocol:         existing_protocol,
            research_master:  rm
          )
        end
      end

      bar.increment! rescue nil
    end

    # Create New COEUS Protocol Records
    log "--- Creating new COEUS protocols"
    bar = ProgressBar.new(new_coeus_award_details.count)

    new_coeus_award_details.each do |ad|
      coeus_protocol = Protocol.new(
        type:                 'COEUS',
        title:                ad['title'],
        mit_award_number:     ad['mit_award_number'],
        sequence_number:      ad['sequence_number'],
        entity_award_number:  ad['entity_award_number'],
        coeus_project_id:     ad['coeus_project_id']
      )

      if coeus_protocol.save
        created_coeus_protocols.append(coeus_protocol.id)

        if ad['rmid'].present? && rm = $research_masters.detect{ |rm| rm.id == ad['rmid'] }
          ResearchMasterCoeusRelation.create(
            protocol:         coeus_protocol,
            research_master:  rm
          )
        end
      end

      bar.increment! rescue nil
    end

    log "--- Updating award numbers from COEUS API: #{awards_hrs.count}"

    existing_coeus_awards_hrs = awards_hrs.select{ |ah| existing_award_numbers.include?(ah['mit_award_number']) }

    log "--- Updating COEUS award numbers"
    bar = ProgressBar.new(existing_coeus_awards_hrs.count)

    existing_coeus_awards_hrs.each do |ah|
      existing_protocol                       = coeus_protocols.detect{ |p| p.mit_award_number == ah['mit_award_number'] }
      existing_protocol.coeus_protocol_number = ah['protocol_number']

      existing_protocol.save(validate: false) if existing_protocol.changed?

      bar.increment! rescue nil
    end

    log "--- Updating users from COEUS API: #{prism_users.count}"

    bar = ProgressBar.new(prism_users.count)

    prism_users.each do |user|
      if user_to_update = $users.detect{ |u| u.net_id == user['netid']}
        user_to_update.update_attribute(:department, user['department'])
      end

      bar.increment! rescue nil
    end

    finish = Time.now

    log "--- :heavy_check_mark: *Done!*"
    log "--- *New protocols total:* #{created_coeus_protocols.count}"
    log "--- *New protocol ids:* #{created_coeus_protocols}"
    log "--- *Finished COEUS_API data import* (#{(finish - start).to_i} Seconds)."

    script_finish = Time.now

    log "- *Script Duration:* #{(script_finish - script_start).to_i} Seconds."

    log ":heavy_check_mark: *Cronjob (COEUS) has completed successfully.*"

    ## turn on auditing
    Protocol.auditing_enabled = true
    ResearchMaster.auditing_enabled = true
    User.auditing_enabled = true
  rescue => error
    Protocol.auditing_enabled = true
    ResearchMaster.auditing_enabled = true
    User.auditing_enabled = true

    log ":heavy_exclamation_mark: *Cronjob (COEUS) has failed unexpectedly.*"
    log error.inspect
  end
end

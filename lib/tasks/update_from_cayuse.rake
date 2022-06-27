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

task update_from_cayuse: :environment do
  $status_notifier   = Teams.new(ENV.fetch('TEAMS_STATUS_WEBHOOK'))
  $full_message = ""

  def log message
    puts "#{message}\n"
    $full_message << message + " <br> "
  end

  begin
    ## turn off auditing for the duration of this script
    Protocol.auditing_enabled = false
    ResearchMaster.auditing_enabled = false

    script_start      = Time.now
    
    $friendly_token    = Devise.friendly_token

    ##Load up Research Masters ahead of time
    $research_masters  = ResearchMaster.all
    $rmc_relations     = ResearchMasterCayuseRelation.all

    

    log "*Cronjob (CAYUSE) has started.*"
    log "- *Beginning data retrieval from APIs...*"
    log "--- *Fetching from CAYUSE_API...*"

    cayuse_api            = ENV.fetch("COEUS_API")
    start                 = Time.now
    projects_with_pi_list = HTTParty.get("#{cayuse_api}/cayuse_projects_with_pi_list", timeout: 500, headers: {'Content-Type' => 'application/json'})

    finish                = Time.now

    log "----- &#x2714; *Done!* (#{(finish - start).to_i} Seconds)"

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

    newly_linked_protocols = []

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
      if research_master = $research_masters.detect{ |rm| rm.id == project['RMID'].to_i }
        # But obviously don't if it already exists
        unless $rmc_relations.any?{ |rmcr| rmcr.protocol_id == existing_protocol.id && rmcr.research_master_id == research_master.id }
          ResearchMasterCayuseRelation.create(
            protocol:         existing_protocol,
            research_master:  research_master
          )
          newly_linked_protocols.append(existing_protocol.id)
        end
      end

      bar.increment! rescue nil
    end
    log "--- &#x2714; *Done!*"

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

        if research_master = $research_masters.detect{ |rm| rm.id == project['RMID'].to_i }
          ResearchMasterCayuseRelation.create(
            protocol: cayuse_protocol,
            research_master: research_master
          )
        end
      end

      bar.increment! rescue nil
    end

    finish = Time.now

    log "--- &#x2714; *Done!*"

    log "--- *Newly linked protocols total:* #{newly_linked_protocols.count}"
    log "--- *Newly linked protocol ids:* #{newly_linked_protocols}"

    log "--- *New protocols total:* #{created_cayuse_protocols.count}"
    log "--- *New protocol ids:* #{created_cayuse_protocols}"

    log "--- *Finished CAYUSE_API data import* (#{(finish - start).to_i} Seconds)."

    script_finish = Time.now

    log "- *Script Duration:* #{(script_finish - script_start).to_i} Seconds."
    log "&#x2714; *Cronjob (CAYUSE) has completed successfully.*"

    $status_notifier.post($full_message)

    ## turn on auditing
    Protocol.auditing_enabled = true
    ResearchMaster.auditing_enabled = true
  rescue => error
    Protocol.auditing_enabled = true
    ResearchMaster.auditing_enabled = true

    log "&#x2757; *Cronjob (CAYUSE) has failed unexpectedly.*"
    log error.inspect
    $status_notifier.post($full_message)
  end
end

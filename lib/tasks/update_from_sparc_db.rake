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

task update_from_sparc_db: :environment do
  begin
    ## turn off auditing for the duration of this script
    Protocol.auditing_enabled       = false
    ResearchMaster.auditing_enabled = false
    User.auditing_enabled           = false

    script_start      = Time.now

    $status_notifier  = Slack::Notifier.new(ENV.fetch('CRONJOB_STATUS_WEBHOOK'))

    $friendly_token   = Devise.friendly_token
    $research_masters = ResearchMaster.eager_load(:pi).all
    $users            = User.all

    def log(message)
      puts "#{message}\n"
#      $status_notifier.ping message
    end

    log '*Cronjob (SPARC) has started.*'

    log '- *Beginning data retrieval from SPARC Database...*'

    begin
      sparc_db = SparcConnection.connection
      valid_connection = true
    rescue StandardError
      log '------- :heavy_exclamation_mark: Cannont connect to SPARC Database'
    end

    if valid_connection
      # log "- *Beginning data retrieval from SPARC Database...*"

      # sparc_api = ENV.fetch("SPARC_API")

      # log "--- *Fetching from SPARC_API...*"

      start       = Time.now
      # protocols   = HTTParty.get("#{sparc_api}/protocols", headers: {'Content-Type' => 'application/json'}, basic_auth: { username: ENV.fetch('SPARC_API_USERNAME'), password: ENV.fetch('SPARC_API_PASSWORD') }, timeout: 500)
      protocols   = SparcHumanSubjectsInfo
      finish      = Time.now
      ldap_search = LdapSearch.new

      # if protocols.code == 401
      #  log "----- :heavy_exclamation_mark:  SPARC_DB Authorization Failed: #{protocols}"
      # elsif protocols.code == 500
      #  log "----- :heavy_exclamation_mark:  SPARC_DB Internal Server Error: #{protocols}"
      # elsif protocols.is_a?(String)
      #  log "----- :heavy_exclamation_mark: Error retrieving protocols from SPARC_DB: #{protocols}"
      # else
      #  log "----- :heavy_check_mark: *Done!* (#{(finish - start).to_i} Seconds)"
      ResearchMaster.update_all(sparc_protocol_id: nil)

      log '- *Beginning SPARC_DB data import...*'
      log "--- Total number of protocols from SPARC_DB: #{protocols.count}"

      start                   = Time.now
      created_sparc_protocols = []
      updated_sparc_protocols = []
      created_sparc_pis       = []

      # Preload SPARC Protocols to improve efficiency
      sparc_protocols           = Protocol.eager_load(:primary_pi).where(type: 'SPARC')
      existing_sparc_ids        = sparc_protocols.pluck(:sparc_id)
      existing_sparc_protocols  = protocols.select { |p| existing_sparc_ids.include?(p['id']) }
      new_sparc_protocols       = protocols.select { |p| existing_sparc_ids.exclude?(p['id']) }

      # Update Existing SPARC Protocol Records
      log '--- Updating existing SPARC protocols'
      bar = ProgressBar.new(existing_sparc_protocols.count)

      existing_sparc_protocols.each do |protocol|
        existing_protocol = sparc_protocols.detect { |p| p.sparc_id == protocol['id'] }

        existing_protocol.short_title = protocol['short_title']
        existing_protocol.long_title  = protocol['title']

        if protocol['ldap_uid']
          net_id = protocol['ldap_uid']
          net_id.slice!('@musc.edu')

          if u = User.where(net_id: net_id).first # this only handles existing users, need to add code to handle creating (does it pull from ADS or not?)
            existing_protocol.primary_pi_id = u.id
          else
            u = User.new(
              net_id: net_id,
              email: protocol['email'],
              first_name: protocol['first_name'],
              last_name: protocol['last_name'],
              department: protocol['pi_department'],
              password: $friendly_token,
              password_confirmation: $friendly_token
            )
            if u.valid?
              u.save(validate: false)
              existing_protocol.primary_pi_id = u.id
              created_sparc_pis.append(u.id)
            end
          end
        end

        if existing_protocol.changed?
          existing_protocol.save(validate: false)
          updated_sparc_protocols.append(existing_protocol.id)
        end

        if protocol['research_master_id'].present? && rm = $research_masters.detect do |rm|
             rm.id == protocol['research_master_id']
           end
          rm.sparc_protocol_id      = existing_protocol.id
          rm.sparc_association_date = DateTime.current unless rm.sparc_association_date

          rm.save(validate: false) if rm.changed?
        end

        begin
          bar.increment!
        rescue StandardError
          nil
        end
      end

      # Create New SPARC Protocol Records
      log '--- Creating new SPARC protocols'
      bar = ProgressBar.new(new_sparc_protocols.count)

      new_sparc_protocols.each do |protocol|
        next unless protocol['research_master_id'].present?

        sparc_protocol = Protocol.new(
          type: protocol['type'],
          short_title: protocol['short_title'],
          long_title: protocol['title'],
          sparc_id: protocol['id'],
          sparc_pro_number: protocol['pro_number']
        )

        if protocol['ldap_uid']
          net_id = protocol['ldap_uid']
          net_id.slice!('@musc.edu')
          pvid = ldap_search.info_query(net_id, false, true)

          if u = User.where(net_id: net_id).first # this only handles existing users, need to add code to handle creating (does it pull from ADS or not?)
            sparc_protocol.primary_pi_id = u.id
          else
            u = User.new(
              net_id: net_id,
              email: protocol['email'],
              first_name: protocol['first_name'],
              last_name: protocol['last_name'],
              department: protocol['pi_department'],
              pvid: pvid.empty? ? nil : pvid[0][:pvid],
              password: $friendly_token,
              password_confirmation: $friendly_token
            )

            if u.valid?
              u.save(validate: false)
              sparc_protocol.primary_pi_id = u.id
              created_sparc_pis.append(u.id)
            end
          end
        end

        created_sparc_protocols.append(sparc_protocol.id) if sparc_protocol.save

        if rm = $research_masters.detect { |rm| rm.id == protocol['research_master_id'] }
          rm.sparc_protocol_id      = sparc_protocol.id
          rm.sparc_association_date = DateTime.current unless rm.sparc_association_date

          rm.save(validate: false) if rm.changed?
        end

        begin
          bar.increment!
        rescue StandardError
          nil
        end
      end

      finish = Time.now

      log '--- :heavy_check_mark: *Done!*'
      log "--- *Updated protocols total:* #{updated_sparc_protocols.count}"
      log "--- *New protocols total:* #{created_sparc_protocols.count}"
      log "--- *New primary pis total:* #{created_sparc_pis.count}"
      log "--- *New primary pi ids:* #{created_sparc_pis}"
      log "--- *Finished SPARC_DB data import* (#{(finish - start).to_i} Seconds)."
    end
  end

  script_finish = Time.now

  log "- *Script Duration:* #{(script_finish - script_start).to_i} Seconds."

  log ':heavy_check_mark: *Cronjob (SPARC) has completed successfully.*'

  ## turn on auditing
  Protocol.auditing_enabled = true
  ResearchMaster.auditing_enabled = true
  User.auditing_enabled = true
rescue StandardError => e
  Protocol.auditing_enabled = true
  ResearchMaster.auditing_enabled = true
  User.auditing_enabled = true

  log ':heavy_exclamation_mark: *Cronjob (SPARC) has failed unexpectedly.*'
  log e.inspect
end

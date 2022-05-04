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
    $users             = User.all

    def log message
      puts "#{message}\n"
     # $status_notifier.ping message
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
      updated_eirb_protocols  = []
      created_eirb_protocols  = []

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

        if existing_protocol.changed?
          existing_protocol.save(validate: false)
          updated_eirb_protocols.append(existing_protocol.id)
        end

        if study['research_master_id'].present?
          if study['pi_net_id']
            net_id = study['pi_net_id']
            net_id.slice!('@musc.edu')
            if u = User.where(net_id: net_id).first
              existing_protocol.primary_pi_id = u.id
              existing_protocol.save(validate: false)
            else
              u = User.new(
                net_id: net_id,
                email: study['pi_email'],
                first_name: study['first_name'],
                last_name: study['last_name'],
                department: study['pi_department'],
                password: $friendly_token,
                password_confirmation:  $friendly_token
              )
              if u.valid?
                u.save(validate: false)
                existing_protocol.primary_pi_id = u.id
                existing_protocol.save(validate: false)
              end
            end
          end

          if (rm = $research_masters.detect{ |rm| rm.id == study['research_master_id'].to_i }) && (study['state'] != 'Withdrawn')
            rm.eirb_protocol_id       = existing_protocol.id
            rm.eirb_association_date  = DateTime.current unless rm.eirb_association_date

            if $validated_states.include?(study['state'])
              rm.eirb_validated = true
              rm.short_title     = study['short_title']
              rm.long_title     = study['title']
            end

            rm.save(validate: false) if rm.changed?
          end
        end

        bar.increment! rescue nil
      end

      # Create New eIRB Protocol Records
      log "--- Creating new eIRB protocols"
      bar = ProgressBar.new(new_eirb_studies.count)

      new_eirb_studies.each do |study|
        if study['research_master_id'].present?
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

          if study['pi_net_id']
            net_id = study['pi_net_id']
            net_id.slice!('@musc.edu')
            if u = User.where(net_id: net_id).first
              eirb_protocol.primary_pi_id = u.id
              eirb_protocol.save(validate: false)
            else
              u = User.new(
                net_id: net_id,
                email: study['pi_email'],
                first_name: study['first_name'],
                last_name: study['last_name'],
                department: study['pi_department'],
                password: $friendly_token,
                password_confirmation:  $friendly_token
              )
              if u.valid?
                u.save(validate: false)
                eirb_protocol.primary_pi_id = u.id
                eirb_protocol.save(validate: false)
              end
            end
          end

          created_eirb_protocols.append(eirb_protocol.id) if eirb_protocol.save

          if (rm = $research_masters.detect{ |rm| rm.id == study['research_master_id'].to_i }) && (study['state'] != 'Withdrawn')
            rm.eirb_protocol_id       = eirb_protocol.id
            rm.eirb_association_date  = DateTime.current unless rm.eirb_association_date

            if $validated_states.include?(study['state'])
              rm.eirb_validated = true
              rm.short_title     = study['short_title']
              rm.long_title     = study['title']
            end

            rm.save(validate: false) if rm.changed?
          end

          bar.increment! rescue nil
        end
      end

      finish = Time.now

      log "--- :heavy_check_mark: *Done!*"
      log "--- *Updated protocols total:* #{updated_eirb_protocols.count}"
      log "--- *New protocols total:* #{created_eirb_protocols.count}"
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

##Old rake task pointing to eirb_api applicaton, new task is "update_form_eirb_db.rake"


# require 'dotenv/tasks'

# task update_from_eirb: :environment do
#   begin
#     ## turn off auditing for the duration of this script
#     Protocol.auditing_enabled = false
#     ResearchMaster.auditing_enabled = false
#     User.auditing_enabled = false

#     script_start      = Time.now

#     $status_notifier   = Slack::Notifier.new(ENV.fetch('CRONJOB_STATUS_WEBHOOK'))

#     $validated_states  = ['Acknowledged', 'Approved', 'Completed', 'Disapproved', 'Exempt Approved', 'Expired',  'Expired - Continuation in Progress', 'External IRB Review Archive', 'Not Human Subjects Research', 'Suspended', 'Terminated']
#     $friendly_token    = Devise.friendly_token
#     $research_masters  = ResearchMaster.eager_load(:pi).all
#     $users             = User.all

#     def log message
#       puts "#{message}\n"
#       $status_notifier.ping message
#     end

#     log "*Cronjob (EIRB) has started.*"

#     log "- *Beginning data retrieval from APIs...*"

#     eirb_api        = ENV.fetch("EIRB_API")
#     eirb_api_token  = ENV.fetch("EIRB_API_TOKEN")

#     log "--- *Fetching from EIRB_API...*"

#     start         = Time.now
#     eirb_studies  = HTTParty.get("#{eirb_api}/studies.json?musc_studies=true", timeout: 500, headers: {'Content-Type' => 'application/json', "Authorization" => "Token token=\"#{eirb_api_token}\""})
#     finish        = Time.now

#     if eirb_studies.is_a?(String)
#       log "----- :heavy_exclamation_mark: Error retrieving protocols from EIRB_API: #{eirb_studies}"
#     else
#       log "----- :heavy_check_mark: *Done!* (#{(finish - start).to_i} Seconds)"

#       ResearchMaster.update_all(eirb_validated: false)

#       log "- *Beginning EIRB_API data import...*"
#       log "--- Total number of protocols from EIRB_API: #{eirb_studies.count}"

#       start                   = Time.now
#       updated_eirb_protocols  = []
#       created_eirb_protocols  = []

#       ResearchMaster.update_all(eirb_protocol_id: nil)

#       # Preload eIRB Protocols to improve efficiency
#       eirb_protocols        = Protocol.eager_load(:primary_pi).where(type: 'EIRB')
#       existing_eirb_ids     = eirb_protocols.pluck(:eirb_id)
#       existing_eirb_studies = eirb_studies.select{ |s| existing_eirb_ids.include?(s['pro_number']) }
#       new_eirb_studies      = eirb_studies.select{ |s| existing_eirb_ids.exclude?(s['pro_number']) }

#       # Update Existing eIRB Protocol Records
#       log "--- Updating existing eIRB protocols"
#       bar = ProgressBar.new(existing_eirb_studies.count)

#       existing_eirb_studies.each do |study|
#         existing_protocol                         = eirb_protocols.detect{ |p| p.eirb_id == study['pro_number'] }
#         existing_protocol.short_title             = study['short_title']
#         existing_protocol.long_title              = study['title']
#         existing_protocol.eirb_state              = study['state']
#         existing_protocol.eirb_institution_id     = study['institution_id']
#         existing_protocol.date_initially_approved = study['date_initially_approved']
#         existing_protocol.date_approved           = study['date_approved']
#         existing_protocol.date_expiration         = study['date_expiration']

#         if existing_protocol.changed?
#           existing_protocol.save(validate: false)
#           updated_eirb_protocols.append(existing_protocol.id)
#         end

#         if study['research_master_id'].present?
#           if study['pi_net_id']
#             net_id = study['pi_net_id']
#             net_id.slice!('@musc.edu')
#             if u = User.where(net_id: net_id).first
#               existing_protocol.primary_pi_id = u.id
#               existing_protocol.save(validate: false)
#             else
#               u = User.new(
#                 net_id: net_id,
#                 email: study['pi_email'],
#                 first_name: study['first_name'],
#                 last_name: study['last_name'],
#                 department: study['pi_department'],
#                 password: $friendly_token,
#                 password_confirmation:  $friendly_token
#               )
#               if u.valid?
#                 u.save(validate: false)
#                 existing_protocol.primary_pi_id = u.id
#                 existing_protocol.save(validate: false)
#               end
#             end
#           end

#           if (rm = $research_masters.detect{ |rm| rm.id == study['research_master_id'].to_i }) && (study['state'] != 'Withdrawn')
#             rm.eirb_protocol_id       = existing_protocol.id
#             rm.eirb_association_date  = DateTime.current unless rm.eirb_association_date

#             if $validated_states.include?(study['state'])
#               rm.eirb_validated = true
#               rm.short_title     = study['short_title']
#               rm.long_title     = study['title']
#             end

#             rm.save(validate: false) if rm.changed?
#           end
#         end

#         bar.increment! rescue nil
#       end

#       # Create New eIRB Protocol Records
#       log "--- Creating new eIRB protocols"
#       bar = ProgressBar.new(new_eirb_studies.count)

#       new_eirb_studies.each do |study|
#         if study['research_master_id'].present?
#           eirb_protocol = Protocol.new(
#             type:                     study['type'],
#             short_title:              study['short_title'] || "",
#             long_title:               study['title'] || "",
#             eirb_id:                  study['pro_number'],
#             eirb_institution_id:      study['institution_id'],
#             eirb_state:               study['state'],
#             date_initially_approved:  study['date_initially_approved'],
#             date_approved:            study['date_approved'],
#             date_expiration:          study['date_expiration']
#           )

#           if study['pi_net_id']
#             net_id = study['pi_net_id']
#             net_id.slice!('@musc.edu')
#             if u = User.where(net_id: net_id).first
#               eirb_protocol.primary_pi_id = u.id
#               eirb_protocol.save(validate: false)
#             else
#               u = User.new(
#                 net_id: net_id,
#                 email: study['pi_email'],
#                 first_name: study['first_name'],
#                 last_name: study['last_name'],
#                 department: study['pi_department'],
#                 password: $friendly_token,
#                 password_confirmation:  $friendly_token
#               )
#               if u.valid?
#                 u.save(validate: false)
#                 eirb_protocol.primary_pi_id = u.id
#                 eirb_protocol.save(validate: false)
#               end
#             end
#           end

#           created_eirb_protocols.append(eirb_protocol.id) if eirb_protocol.save

#           if (rm = $research_masters.detect{ |rm| rm.id == study['research_master_id'].to_i }) && (study['state'] != 'Withdrawn')
#             rm.eirb_protocol_id       = eirb_protocol.id
#             rm.eirb_association_date  = DateTime.current unless rm.eirb_association_date

#             if $validated_states.include?(study['state'])
#               rm.eirb_validated = true
#               rm.short_title     = study['short_title']
#               rm.long_title     = study['title']
#             end

#             rm.save(validate: false) if rm.changed?
#           end

#           bar.increment! rescue nil
#         end
#       end

#       finish = Time.now

#       log "--- :heavy_check_mark: *Done!*"
#       log "--- *Updated protocols total:* #{updated_eirb_protocols.count}"
#       log "--- *New protocols total:* #{created_eirb_protocols.count}"
#       log "--- *Finished EIRB_API data import* (#{(finish - start).to_i} Seconds)."
#     end

#     script_finish = Time.now

#     log "- *Script Duration:* #{(script_finish - script_start).to_i} Seconds."

#     log ":heavy_check_mark: *Cronjob (EIRB) has completed successfully.*"

#     ## turn on auditing
#     Protocol.auditing_enabled = true
#     ResearchMaster.auditing_enabled = true
#     User.auditing_enabled = true
#   rescue => error
#     Protocol.auditing_enabled = true
#     ResearchMaster.auditing_enabled = true
#     User.auditing_enabled = true

#     log ":heavy_exclamation_mark: *Cronjob (EIRB) has failed unexpectedly.*"
#     log error.inspect
#   end
# end
# Copyright © 2022 MUSC Foundation for Research Development~
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


task update_from_eirb_db: :environment do
  $status_notifier = if Rails.env.development?
    stub = Object.new
    def stub.post(m)
      puts "#{m}"
    end
    stub
  else
    Teams.new(ENV.fetch('TEAMS_STATUS_WEBHOOK'))
  end

  $full_message = ""

  def log message
    puts "#{message}\n"
    $full_message << message + " <br> "
  end

  def validated_state_checker(arr, val)
    arr.map(&:downcase).include?(val.downcase)
  end

  def valid_int?(val)
    val.to_i <= 2147483647 # max value for signed INT
  end

  def update_pi(rm, study, protocol)
    if protocol.primary_pi_id.present? && rm.pi_id != protocol.primary_pi_id

      if rm.previous_pi_id.nil? && rm.original_pi_id.nil?
        rm.original_pi_id = rm.pi_id
      end

      rm.previous_pi_id = rm.pi_id
      rm.pi_id = protocol.primary_pi_id
      rm.pi_change_date = DateTime.current

      begin
        ResearchMaster.auditing_enabled = true
        saved = rm.save(validate: false)
      ensure
        ResearchMaster.auditing_enabled = false
      end

      if saved
        begin
          existing = User.find_by(id: rm.previous_pi_id)
          current  = User.find_by(id: rm.pi_id)
          creator  = User.find_by(id: rm.creator_id)
          if existing && current && creator
            if ENV['SUPPRESS_PI_MAILER'] != 'true'
              PiMailer.notify_pis(rm, existing, current, creator).deliver_now
            end
          end
        rescue => e
          log "--- *Error sending PI mailer: #{e.message}*"
        end
        return true
      end
    end
    return false
  end

  def restore_original_pi(no_longer_linked_to_validated_eirb_study)
    ResearchMaster.where(id: no_longer_linked_to_validated_eirb_study).each do |rm|
      next unless rm.original_pi_id.present? && rm.pi_id != rm.original_pi_id

      pi_before_restore = User.find_by(id: rm.pi_id)
      pi_after_restore = User.find_by(id: rm.original_pi_id)
      creator = User.find_by(id: rm.creator_id)

      rm.previous_pi_id = rm.pi_id
      rm.pi_id = rm.original_pi_id
      rm.pi_change_date = DateTime.current

      if rm.save(validate: false)
        log "--- *Restored original PI for RMID #{rm.id} (Previous PI: #{rm.previous_pi_id}, New PI: #{rm.pi_id})*"

        if pi_before_restore && pi_after_restore && creator
          begin
            PiMailer.notify_pis_on_restore(rm, pi_before_restore, pi_after_restore, creator).deliver_now
          rescue => e
            log "--- *Error sending PI mailer: #{e.message}*"
          end
        end
      else
        log "--- *Failed to restore original PI for RMID #{rm.id}*"
      end
    end
  end

  def update_rm(remote_study, local_protocol)
    if (rm = $research_masters.detect{ |rm| rm.id == remote_study['rmid'].to_i }) && (remote_study['project_status'] != 'Withdrawn')
      rm.eirb_protocol_id       = local_protocol.id
      rm.eirb_association_date  = DateTime.current unless rm.eirb_association_date

      if validated_state_checker($validated_states, remote_study['project_status'])
        rm.eirb_validated = true
        rm.short_title    = remote_study['short_title']
        rm.long_title     = remote_study['title']

        update_pi(rm, remote_study, local_protocol)
      end

      if rm.changed?
        rm.save(validate: false)
      end
    end
  end

  begin
    ## turn off auditing for the duration of this script
    Protocol.auditing_enabled = false
    ResearchMaster.auditing_enabled = false
    User.auditing_enabled = false

    script_start      = Time.now

    $validated_states  = ['Acknowledged', 'Approved', 'Completed', 'Disapproved', 'Exempt Approved', 'Exempt Complete', 'Expired',  'Expired - Continuation In Progress', 'External IRB Review Archive', 'Not Human Subjects Research', 'Overdue Study Status', 'Suspended', 'Terminated']
    $friendly_token    = Devise.friendly_token
    $research_masters  = ResearchMaster.eager_load(:pi)
    $users             = User.all

    log "*Cronjob (EIRB) has started.*"

    log "--- *Connecting to EIRB Database...*"

    valid_connection = false
    begin
      eirb_db = EirbConnection.connection
      valid_connection = true
    rescue => e
      log "--- *Cannot connect to EIRB Database: #{e.message}...*"
    end

    if valid_connection
      log "--- *Beginning data retrieval from EIRB Database...*"

      start         = Time.now
      eirb_studies = EirbStudy.is_musc.filter_out_preserve_state.filter_invalid_pro_numbers
      finish        = Time.now
      log "--- *Done!* (#{(finish - start).to_i} Seconds)"

      existing_eirb_associated_rmids = []
      existing_eirb_associated_and_validated_rmids = []
      eirb_studies.each do |study|
        next unless study['rmid'].present? && valid_int?(study['rmid'].to_i)
        existing_eirb_associated_rmids << study['rmid'].to_i

        if study['project_status'] != 'Withdrawn' && validated_state_checker($validated_states, study['project_status'])
          existing_eirb_associated_and_validated_rmids << study['rmid'].to_i
        end
      end

      no_longer_linked_to_validated_eirb_study = ResearchMaster.where.not(id: existing_eirb_associated_and_validated_rmids).where.not(eirb_protocol_id: nil).pluck(:id)
      if no_longer_linked_to_validated_eirb_study.any?
        restore_original_pi(no_longer_linked_to_validated_eirb_study)
      end

      ResearchMaster.where.not(id: existing_eirb_associated_rmids)
                    .where.not(eirb_protocol_id: nil)
                    .update_all(eirb_protocol_id: nil)

      ResearchMaster.where(eirb_validated: true)
                    .where.not(id: existing_eirb_associated_and_validated_rmids)
                    .update_all(eirb_validated: false)

      log "--- *Beginning EIRB data import...*"
      log "--- *Total number of protocols from EIRB Database: #{eirb_studies.count}"

      start                   = Time.now
      updated_eirb_protocols  = []
      created_eirb_protocols  = []

      # Preload eIRB Protocols to improve efficiency
      eirb_protocols        = Protocol.eager_load(:primary_pi).where(type: 'EIRB')
      existing_eirb_ids     = eirb_protocols.pluck(:eirb_id)
      existing_eirb_studies = eirb_studies.select{ |s| existing_eirb_ids.include?(s['pro_number']) }
      new_eirb_studies      = eirb_studies.select{ |s| existing_eirb_ids.exclude?(s['pro_number']) }

      # Update Existing eIRB Protocol Records
      log "--- *Updating existing eIRB protocols"
      bar = ProgressBar.new(existing_eirb_studies.count)

      existing_eirb_studies.each do |study|
        existing_protocol                         = eirb_protocols.detect{ |p| p.eirb_id == study['pro_number'] }
        existing_protocol.short_title             = study['short_title']
        existing_protocol.long_title              = study['title']
        existing_protocol.eirb_state              = study['project_status']
        existing_protocol.eirb_institution_id     = study['institution_id']
        existing_protocol.date_initially_approved = study['date_initially_approved']
        existing_protocol.date_approved           = study['date_approved']
        existing_protocol.date_expiration         = study['date_expiration']
        existing_protocol.review_type             = study['review_type']
        existing_protocol.irb_review_request      = study['irb_review_request']
        existing_protocol.irb_committee_name      = study['IRB committee name']
        existing_protocol.external_irb_of_record  = study['External IRB of Record']
        existing_protocol.other_external_irb_text = study['Other External IRB Text']
        existing_protocol.clinical_study_phase    = study['Clinical study phase']
        existing_protocol.status_description      = study['status_description']

        if existing_protocol.changed?
          existing_protocol.save(validate: false)
          updated_eirb_protocols.append(existing_protocol.id)
        end

        if study['rmid'].present?
          if study['principal_investigator_id']
            net_id = study['principal_investigator_id']
            net_id.slice!('@musc.edu')
            if u = User.where(net_id: net_id).first
              existing_protocol.primary_pi_id = u.id
              existing_protocol.save(validate: false)
            else
              u = User.new(
                net_id: net_id,
                email: study['principal_investigator_email_address'],
                first_name: study['principal_investigator_first_name'],
                last_name: study['principal_investigator_last_name'],
                department: study['principal_investigator_department'],
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
          update_rm(study, existing_protocol)
        end
        bar.increment! rescue nil
      end

      # Create New eIRB Protocol Records
      log "--- Creating new eIRB protocols"
      bar = ProgressBar.new(new_eirb_studies.count)

      new_eirb_studies.each do |study|
        if study['rmid'].present?
          eirb_protocol = Protocol.new(
            type:                     'EIRB',
            short_title:              study['short_title'] || "",
            long_title:               study['title'] || "",
            eirb_id:                  study['pro_number'],
            eirb_institution_id:      study['institution_id'],
            eirb_state:               study['project_status'],
            date_initially_approved:  study['date_initially_approved'],
            date_approved:            study['date_approved'],
            date_expiration:          study['date_expiration'],
            review_type:              study['review_type'],
            irb_review_request:       study['irb_review_request'],
            irb_committee_name:       study['IRB committee name'],
            external_irb_of_record:   study['External IRB of Record'],
            other_external_irb_text:  study['Other External IRB Text'],
            clinical_study_phase:     study['Clinical study phase'],
            status_description:       study['status_description']
          )

          if study['principal_investigator_id']
            net_id = study['principal_investigator_id']
            net_id.slice!('@musc.edu')
            if u = User.where(net_id: net_id).first
              eirb_protocol.primary_pi_id = u.id
              eirb_protocol.save(validate: false)
            else
              u = User.new(
                net_id: net_id,
                email: study['principal_investigator_email_address'],
                first_name: study['principal_investigator_first_name'],
                last_name: study['principal_investigator_last_name'],
                department: study['principal_investigator_department'],
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

          update_rm(study, eirb_protocol)
        end
        bar.increment! rescue nil
      end

      finish = Time.now

      log "--- *Done!*"
      log "--- *Updated protocols total:* #{updated_eirb_protocols.count}"
      log "--- *New protocols total:* #{created_eirb_protocols.count}"
      log "--- *Finished EIRB data import* (#{(finish - start).to_i} Seconds)."

      script_finish = Time.now

      log "--- *Script Duration:* #{(script_finish - script_start).to_i} Seconds."

      log "--- *Cronjob (EIRB) has completed successfully.*"
      $status_notifier.post($full_message)
    end

    ## turn on auditing
    Protocol.auditing_enabled = true
    ResearchMaster.auditing_enabled = true
    User.auditing_enabled = true
  rescue => error
    Protocol.auditing_enabled = true
    ResearchMaster.auditing_enabled = true
    User.auditing_enabled = true

    log "--- *Cronjob (EIRB) has failed unexpectedly.*"
    log error.inspect
    $status_notifier.post($full_message)
    ExceptionNotifier.notify_exception(error)
  end
end

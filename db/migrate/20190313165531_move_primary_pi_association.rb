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

class MovePrimaryPiAssociation < ActiveRecord::Migration[5.1]
  class PrimaryPi < ApplicationRecord
    def name
      [self.first_name, self.last_name].join(' ')
    end
  end

  def up
    puts 'Migrating Primary PI data. This may take a while...'
    puts 'Fetching Protocols from SPARC API...'
    sparc_api       = ENV.fetch("SPARC_API")
    sparc_protocols = HTTParty.get("#{sparc_api}/protocols", timeout: 500, headers: {'Content-Type' => 'application/json'})

    puts 'Fetching Studies from eIRB API...'
    eirb_api        = ENV.fetch("EIRB_API")
    eirb_api_token  = ENV.fetch("EIRB_API_TOKEN")
    eirb_studies    = HTTParty.get("#{eirb_api}/studies.json?musc_studies=true", timeout: 500, headers: {'Content-Type' => 'application/json', "Authorization" => "Token token=\"#{eirb_api_token}\""})

    if sparc_protocols.is_a?(String)
      raise "Something went wrong with the SPARC API. Check that it is working correctly to continue."
    elsif eirb_studies.is_a?(String)
      raise "Something went wrong with the eIRB API. Check that it is working correctly to continue."
    else
      puts 'Migrating data...'
      ActiveRecord::Base.transaction do
        add_reference :protocols, :primary_pi, after: :long_title, index: true

        missing_pis = []
        new_or_found_users = {}
        not_found_users = {}

        if Rails.env != 'production'
          bar = ProgressBar.new(PrimaryPi.count)
        end

        PrimaryPi.all.each do |primary_pi|
          protocol = Protocol.find(primary_pi.protocol_id)

          # Check for the user in the system using the net_id
          if primary_pi.net_id && (user = User.find_by(net_id: primary_pi.net_id.gsub('@musc.edu', '')))
            protocol.update_attribute(:primary_pi_id, user.id)
          # Cross-check with LDAP using the net_id
          elsif primary_pi.net_id && (ldap_results = LdapSearch.new.info_query(primary_pi.net_id.gsub('@musc.edu', ''), false, true)) && ldap_results.count == 1
            record  = ldap_results.first
            user    = User.where(email: record[:email]).first_or_create(password: Devise.friendly_token[0,20], net_id: record[:netid], name: [record[:first_name], record[:last_name]].join(' '), first_name: record[:first_name], last_name: record[:last_name], middle_initial: record[:middle_initial], pvid: record[:pvid])
            new_or_found_users[user.name] = user # Cache the user for future calls to avoid repeated LDAP checks
            protocol.update_attribute(:primary_pi_id, user.id)
          # Check cached users for optimization
          elsif user = new_or_found_users[primary_pi.name]
            protocol.update_attribute(:primary_pi_id, user.id)
          # Cross-check with the SPARC API to find the net_id
          elsif (sparc_protocol = sparc_protocols.detect{ |sp| sp['id'] == protocol.sparc_id }) && sparc_protocol['first_name'] == primary_pi.first_name && sparc_protocol['last_name'] == primary_pi.last_name && (ldap_results = LdapSearch.new.info_query(sparc_protocol['ldap_uid'].try(:gsub, '@musc.edu', ''), false, true)) && ldap_results.count == 1
            record  = ldap_results.first
            user    = User.where(email: record[:email]).first_or_create(password: Devise.friendly_token[0,20], net_id: record[:netid], name: [record[:first_name], record[:last_name]].join(' '), first_name: record[:first_name], last_name: record[:last_name], middle_initial: record[:middle_initial], pvid: record[:pvid])
            new_or_found_users[user.name] = user # Cache the user for future calls to avoid repeated LDAP checks
            protocol.update_attribute(:primary_pi_id, user.id)
          # Cross-check with the eIRB API to find the net_id
          elsif (eirb_study = eirb_studies.detect{ |es| es['pro_number'] == protocol.eirb_id }) && eirb_study['first_name'] == primary_pi.first_name && eirb_study['last_name'] == primary_pi.last_name && (ldap_results = LdapSearch.new.info_query(eirb_study['pi_net_id'].try(:gsub, '@musc.edu', ''), false, true)) && ldap_results.count == 1
            record  = ldap_results.first
            user    = User.where(email: record[:email]).first_or_create(password: Devise.friendly_token[0,20], net_id: record[:netid], name: [record[:first_name], record[:last_name]].join(' '), first_name: record[:first_name], last_name: record[:last_name], middle_initial: record[:middle_initial], pvid: record[:pvid])
            new_or_found_users[user.name] = user # Cache the user for future calls to avoid repeated LDAP checks
            protocol.update_attribute(:primary_pi_id, user.id)
          else
            # Cross-check with LDAP using the First and Last name
            if !not_found_users[primary_pi.name] && (ldap_results = LdapSearch.new.info_query(primary_pi.first_name, false) & LdapSearch.new.info_query(primary_pi.last_name, false)) && ldap_results.count == 1
              record  = ldap_results.first
              user    = User.where(email: record[:email]).first_or_create(password: Devise.friendly_token[0,20], net_id: record[:netid], name: [record[:first_name], record[:last_name]].join(' '), first_name: record[:first_name], last_name: record[:last_name], middle_initial: record[:middle_initial], pvid: record[:pvid])
              new_or_found_users[user.name] = user # Cache the user for future calls to avoid repeated LDAP checks
              protocol.update_attribute(:primary_pi_id, user.id)
            else
              not_found_users[primary_pi.name] = true # Cache for future calls to avoid repeated LDAP checks
              missing_pis << "Protocol #{protocol.id} - Primary PI #{primary_pi.name} (#{primary_pi.net_id || 'No NetID'})"
            end
          end

          if Rails.env != 'production'
            bar.increment! rescue nil
          end
        end

        if missing_pis.any?
          puts "#"*50
          puts "#"*50
          puts "#"*50
          puts missing_pis.inspect
          puts "#"*50
          puts "#"*50
          puts "#"*50
        end
      end
    end
  end

  def down
    remove_reference :protocols, :primary_pi
  end
end

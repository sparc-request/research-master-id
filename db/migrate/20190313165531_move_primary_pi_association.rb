class MovePrimaryPiAssociation < ActiveRecord::Migration[5.1]
  class PrimaryPi < ApplicationRecord
    def name
      [self.first_name, self.last_name].join(' ')
    end
  end

  def up
    ActiveRecord::Base.transaction do
      add_reference :protocols, :primary_pi, after: :long_title, index: true
      missing_pis = []
      new_or_found_users = {}
      not_found_users = {}

      PrimaryPi.all.each do |primary_pi|
        protocol = Protocol.find(primary_pi.protocol_id)

        if primary_pi.net_id && user = User.find_by(net_id: primary_pi.net_id.gsub('@musc.edu', ''))
          protocol.update_attribute(:primary_pi_id, user.id)
        elsif user = new_or_found_users[primary_pi.name]
          protocol.update_attribute(:primary_pi_id, user.id)
        else
          if !not_found_users[primary_pi.name] && (ldap_results = LdapSearch.new.info_query(primary_pi.first_name) & LdapSearch.new.info_query(primary_pi.last_name)) && ldap_results.count == 1
            record = ldap_results.first
            user = User.where(email: record[:email]).first_or_create(password: Devise.friendly_token[0,20], net_id: record[:netid], name: [record[:first_name], record[:last_name]].join(' '), first_name: record[:first_name], last_name: record[:last_name], middle_initial: record[:middle_initial], pvid: record[:pvid])
            new_or_found_users[user.name] = user # Cache the user for future calls to avoid repeated LDAP checks
            protocol.update_attribute(:primary_pi_id, user.id)
          else
            not_found_users[primary_pi.name] = true # Cache for future calls to avoid repeated LDAP checks
            missing_pis << "Protocol #{protocol.id} - Primary PI #{primary_pi.name} (#{primary_pi.net_id || 'No NetID'})"
          end
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

  def down
    remove_reference :protocols, :primary_pi
  end
end

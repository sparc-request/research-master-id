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

class LdapSearch

  def self.interfolio_users
    @interfolio_users ||= HTTParty.get("#{ENV.fetch("COEUS_API")}/interfolio", timeout: 500, headers: {'Content-Type' => 'application/json'})
  end

  def employee_number_query(employee_number)
    ldaps = connect_to_ldap()

    filter = Net::LDAP::Filter.eq('muscpvid', employee_number)

    ldaps.each do |key,ldap|
      ldap.search(:base => ldap.base, :filter => filter) do |entry|
        next if key == 'musc' && entry[:muscactiveaccount].include?('FALSE') # skip inactive accounts
        user = { first_name: entry[:givenname].first, last_name: entry[:sn].first, middle_initial: nil, mail: nil, netid: nil, pvid: entry[:muscpvid].first }

        if key == 'musc'
          user[:mail] = entry[:mail].first
          user[:netid] = entry['muscaccountname'].first
          user[:middle_initial] = entry['middlename'].first
        elsif key == 'affiliate'
          user[:mail] = entry[:userprincipalname].first
          user[:netid] = entry['samaccountname'].first
        end

        return user
      end
    end
  end

  def info_query(name, active_only=true, netid_only=false, search_term=nil)
    ldaps             = connect_to_ldap
    user_info         = []

    # MUSC givenname, sn, mail, muscaccountname
    # Affiliate givenname, sn, userprincipalname, samaccountname
    if netid_only
      fields = ['muscaccountname', 'samaccountname']
    else
      if search_term
        fields = case search_term
          when 'name' then ['givenname', 'sn']
          when 'email' then ['mail', 'userprincipalname']
          else ['muscaccountname', 'samaccountname']
        end
      else
        fields = ['givenname', 'sn', 'mail', 'userprincipalname', 'muscaccountname', 'samaccountname']
      end
    end

    filter = fields.map { |f| Net::LDAP::Filter.eq(f, name + "*") }.inject(:|)

    ldaps.each do |key,ldap|
      ldap.search(:base => ldap.base, :filter => filter) do |entry|
        next if active_only && key == 'musc' && (entry[:muscactiveaccount].include?('FALSE') || entry[:mail].blank?)  # skip inactive accounts or ones without an e-mail address
        entry_info = { name: nil, first_name: entry[:givenname].first, last_name: entry[:sn].first, middle_initial: nil, email: nil, netid: nil, pvid: entry[:muscpvid].first, active: true, affiliate: false}

        if key == 'musc'
          entry_info[:name] = "#{entry[:givenname].first} #{entry[:middlename].first} #{entry[:sn].first}"
          entry_info[:middle_initial] = entry['middlename'].first
          entry_info[:email] = entry[:mail].first
          entry_info[:netid] = entry[:muscaccountname].first
          if !active_only
            entry_info[:active] = entry[:muscactiveaccount].include?('FALSE') ? false : true
          end
        elsif key == 'affiliate'
          entry_info[:name] = "#{entry[:givenname].first} #{entry[:sn].first}"
          entry_info[:email] = entry[:userprincipalname].first
          entry_info[:netid] = entry[:samaccountname].first
          entry_info[:affiliate] = true
        end

        if department = interfolio_query(entry_info[:netid], LdapSearch.interfolio_users)
          entry_info[:department] = department
          entry_info[:interfolio_user] = true
        else
          entry_info[:department] = department
          entry_info[:interfolio_user] = false
        end

        user_info << entry_info
      end
    end

    user_info.sort_by{ |info| info[:name] }
  end

  private

  def connect_to_ldap()
    host = '128.23.180.126'
    port = 636
    encryption = { method: :simple_tls, tls_options: { verify_mode: OpenSSL::SSL::VERIFY_NONE } }
    auth = { method: :simple, username: ENV.fetch('ADS_USERNAME'), password: ENV.fetch('ADS_PASSWORD') }

    { 'affiliate' =>
      Net::LDAP.new(host: host,
                    port: port,
                    encryption: encryption,
                    base: 'ou=NonMuscResearch,dc=clinlan,dc=local',
                    auth: auth
                   ),
      'musc' =>
      Net::LDAP.new(host: host,
                    port: port,
                    encryption: encryption,
                    base: 'ou=People,dc=clinlan,dc=local',
                    auth: auth
                   )
    }
  end

  def interfolio_query(netid, interfolio_users)
    if user = interfolio_users.detect{|user| user["netid"] == netid }
      return user['department']
    end
  end
end


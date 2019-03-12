class LdapSearch

  def self.prism_users
    @prism_users ||= HTTParty.get("#{ENV.fetch("COEUS_API")}/prism", timeout: 500, headers: {'Content-Type' => 'application/json'})
  end

  def employee_number_query(employee_number)
    ldaps = connect_to_ldap()

    filter = Net::LDAP::Filter.eq('muscpvid', employee_number)

    ldaps.each do |key,ldap|
      ldap.search(:base => ldap.base, :filter => filter) do |entry|
        user = { first_name: entry[:givenname].first, last_name: entry[:sn].first, mail: nil, netid: nil }

        if key == 'musc'
          user[:mail] = entry[:mail].first
          user[:netid] = entry['muscaccountname'].first
        elsif key == 'affiliate'
          user[:mail] = entry[:userprincipalname].first
          user[:netid] = entry['samaccountname'].first
        end

        return user
      end
    end
  end

  def info_query(name)
    ldaps             = connect_to_ldap
    user_info         = []

    # MUSC givenname, sn, mail, muscaccountname
    # Affiliate givenname, sn, userprincipalname, samaccountname
    fields = ['givenname', 'sn', 'mail', 'userprincipalname', 'muscaccountname', 'samaccountname']

    filter = fields.map { |f| Net::LDAP::Filter.contains(f, name) }.inject(:|)

    ldaps.each do |key,ldap|
      ldap.search(:base => ldap.base, :filter => filter) do |entry|
        next if key == 'musc' && (entry[:muscactiveaccount].include?('FALSE') || entry[:mail].blank?)  # skip inactive accounts or ones without an e-mail address
        entry_info = { name: "#{entry[:givenname].first} #{entry[:sn].first}" }

        if key == 'musc'
          entry_info[:email] = entry[:mail].first
          entry_info[:netid] = entry[:muscaccountname].first
        elsif key == 'affiliate'
          entry_info[:email] = entry[:userprincipalname].first
          entry_info[:netid] = entry[:samaccountname].first
        end

        if department = prism_query(entry_info[:netid], LdapSearch.prism_users)
          entry_info[:department] = department
          entry_info[:prism_user] = true
        elsif department = User.find_by_net_id(entry_info[:netid]).try(:department)
          entry_info[:department] = department
          entry_info[:prism_user] = false
        end

        user_info << entry_info
      end
    end

    user_info.sort_by{ |info| info[:name] }
  end

  private

  def connect_to_ldap()
    host = 'ads.musc.edu'
    port = 636
    encryption = 'simple_tls'
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

  def prism_query(netid, prism_users)
    if user = prism_users.detect{|user| user["netid"] == netid }
      return user['department']
    end
  end
end


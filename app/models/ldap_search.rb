class LdapSearch

  def self.prism_users
    @prism_users ||= HTTParty.get("#{ENV.fetch("COEUS_API")}/prism", timeout: 500, headers: {'Content-Type' => 'application/json'})
  end

  def email_query(uid)
    ldaps = connect_to_ldap
    fields = ['muscaccountname', 'samaccountname']

    filter = fields.map { |f| Net::LDAP::Filter.eq(f, uid) }.inject(:|)

    ldaps.each do |ldap|
      ldap.search(:base => ldap.base, :filter => filter) do |entry|
        return entry[:mail].present? ? entry[:mail].first : entry[:userprincipalname].first
      end
    end
  end

  def employee_number_query(employee_number)
    ldaps = connect_to_ldap()

    ldaps.each do |ldap|
      ldap.search(:base => ldap.base, :filter => filter_query('muscpvid', employee_number)) do |entry|
        user = { first_name: entry[:givenname].first, last_name: entry[:sn].first, mail: nil, netid: nil }

        if entry[:mail].present?
          user[:mail] = entry[:mail].first
          user[:netid] = entry['muscaccountname'].first
        else
          user[:mail] = entry[:userprincipalname].first
          user[:netid] = entry['samaccountname'].first
        end

        return user
      end
    end
  end

  def info_query(name)
    ####TODO should this work for affiliate netid users ####
    ldaps             = connect_to_ldap
    user_info         = []
    composite_filter  = (filter_query('cn', "#{name}*") | filter_query('mail', "#{name}*")) & filter_query('mail', "*") | filter_query('sn', "#{name}*")

    ldaps.each do |ldap|
      ldap.search(:base => ldap.base, :filter => composite_filter) do |entry|
        entry_info = { name: entry[:cn].first, email: entry[:mail].first }

        if department = prism_query(entry[:uid], LdapSearch.prism_users)
          entry_info[:department] = department
          entry_info[:prism_user] = true
        elsif department = User.find_by_net_id(entry[:uid]).try(:department)
          entry_info[:department] = department
          entry_info[:prism_user] = false
        end

        user_info << entry_info
      end
    end

    user_info.sort_by{ |info| info[:name] }
  end

  def name_query(uid)
    ####TODO should this work for affiliate netid users ####
    ldaps = connect_to_ldap
    ldaps.each do |ldap|
      ldap.search(:base => ldap.base, :filter => filter_query('uid', uid)) do |entry|
        return entry[:cn].first
      end
    end
  end

  def net_id_query(email)
    ####TODO should this work for affiliate netid users ####
    ldaps = connect_to_ldap
    ldaps.each do |ldap|
      ldap.search(:base => ldap.base, :filter => filter_query('mail', email)) do |entry|
        return entry[:uid].first
      end
    end
  end

  private

  def connect_to_ldap()
    host = 'ads.musc.edu'
    port = 636
    encryption = 'simple_tls'
    auth = { method: :simple, username: ENV.fetch('ADS_USERNAME'), password: ENV.fetch('ADS_PASSWORD') }

    [
      Net::LDAP.new(host: host,
                    port: port,
                    encryption: encryption,
                    base: 'ou=NonMuscResearch,dc=clinlan,dc=local',
                    auth: auth
                   ),
      Net::LDAP.new(host: host,
                    port: port,
                    encryption: encryption,
                    base: 'ou=People,dc=clinlan,dc=local',
                    auth: auth
                   )
    ]
  end

  def filter_query(parameter, query)
    Net::LDAP::Filter.eq(parameter, query)
  end

  def prism_query(netid, prism_users)
    if user = prism_users.detect{|user| user["netid"] == netid.first }
      user['department']
    end
  end
end


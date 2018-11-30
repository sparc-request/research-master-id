class LdapSearch

  def self.prism_users
    @prism_users ||= HTTParty.get("#{ENV.fetch("COEUS_API")}/prism", timeout: 500, headers: {'Content-Type' => 'application/json'})
  end

  def email_query(uid)
    ldap = connect_to_ldap
    ldap.search(:base => ldap.base, :filter => filter_query('uid', uid)) do |entry|
      return entry[:mail].first
    end
  end

  def employee_number_query(employee_number)
    ldap = connect_to_ldap
    ldap.search(:base => ldap.base, :filter => filter_query('muscedupersonpvid', employee_number)) do |entry|
      return entry[:mail].first
    end
  end

  def info_query(name)
    ldap = connect_to_ldap
    names = []
    composite_filter = (filter_query('cn', "#{name}*") | filter_query('mail', "#{name}*")) & filter_query('mail', "*") | filter_query('sn', "#{name}*")
    ldap.search(:base => ldap.base, :filter => composite_filter) do |entry|
      department = prism_query(entry[:uid], LdapSearch.prism_users)
      new_array = (department != nil) ? (entry[:cn] + entry[:mail] + [department]) : (entry[:cn] + entry[:mail])
      names.push(new_array)
    end
    names.sort
  end

  def name_query(uid)
    ldap = connect_to_ldap
    ldap.search(:base => ldap.base, :filter => filter_query('uid', uid)) do |entry|
      return entry[:cn].first
    end
  end

  def net_id_query(email)
    ldap = connect_to_ldap
    ldap.search(:base => ldap.base, :filter => filter_query('mail', email)) do |entry|
      return entry[:uid].first
    end
  end

  private

  def connect_to_ldap
    Net::LDAP.new(host: 'authldap.musc.edu',
                  port: 636,
                  encryption: 'simple_tls',
                  base: 'ou=people,dc=musc,dc=edu'
                 )
  end

  def filter_query(parameter, query)
    Net::LDAP::Filter.eq(parameter, query)
  end

  def prism_query(netid, prism_users)
    user = prism_users.select {|user| user["netid"] == netid.first }.first

    user['department'] if user
  end
end


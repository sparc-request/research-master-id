class LdapSearch

  def email_query(uid)
    ldap = connect_to_ldap
    ldap.search(:base => ldap.base, :filter => filter_query('uid', uid)) do |entry|
      return entry[:mail].first
    end
  end

  def info_query(name)
    ldap = connect_to_ldap
    names = []
    ldap.search(:base => ldap.base, :filter => filter_query('cn', "#{name}*")) do |entry|
      new_array = entry[:cn] + entry[:mail]
      names.push(new_array)
    end
    names
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
end


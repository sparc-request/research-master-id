task find_missing_netids: :environment do

  ldap_search = LdapSearch.new

  sparc_api = ENV.fetch('SPARC_API')

  identities = HTTParty.get(
    "#{sparc_api}/identities",
    timeout: 500,
    headers: { 'Content-Type' => 'application/json' }
  )

  puts "Deleting old netids to get rid of duplicates..."
  User.all.each do |user|
    user.update_attributes(net_id: nil)
  end

  puts "Filling in new netids from ldap..."
   User.all.each do |user|
    net_id = ldap_search.net_id_query(user.email)
    user.update_attribute(:net_id, net_id)
  end

  puts 'Filling in any netids ldap missed from sparc identities...'
  identities.each do |identity|
    if User.exists?(email: identity['email'])
      user = User.find_by(email: identity['email'])
      if user.net_id == '[]' || user.net_id == nil
        user.update_attribute(:net_id, identity['ldap_uid'].remove('@musc.edu'))
      end
    end
  end

  users_without_name = User.where(name: nil)

  puts 'Fixing missing names...'
  users_without_name.each do |user|
    net_id = user.net_id
    found_name = ldap_search.name_query(net_id)
    user.update_attribute(:name, found_name)
  end
end

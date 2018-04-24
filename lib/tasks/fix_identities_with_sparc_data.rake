task fix_identities_with_sparc_data: :environment do
  sparc_api = ENV.fetch('SPARC_API')

  identities = HTTParty.get(
    "#{sparc_api}/identities",
    timeout: 500,
    headers: { 'Content-Type' => 'application/json' }
  )

  identities.each do |identity|
    if User.exists?(email: identity['email'])
      user = User.find_by(email: identity['email'])
      if user.net_id == '[]'
        user.update_attribute(:net_id, identity['ldap_uid'].remove('@musc.edu'))
      end
      if user.name == '[]'
        user.update_attribute(:name, identity['first_name'] + identity['last_name'])
      end
    end
  end

  User.find(698).update!(email: 'fabie@musc.edu', net_id: 'jof210', name: 'Joshua Fabie')
  User.find(195).update!(email: 'axon@musc.edu', net_id: 'axon', name: 'Robert Axon')
  User.find(178).update!(email: 'nelsonjd@musc.edu', net_id: 'jod9', name: 'Joni Nelson')

end

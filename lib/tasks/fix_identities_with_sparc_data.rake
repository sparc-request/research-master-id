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
      if user.net_id == '[]' || user.net_id == nil
        user.update_attribute(:net_id, identity['ldap_uid'].remove('@musc.edu'))
      end
      if user.name == '[]' || user.name == nil
        user.update_attribute(:name, identity['first_name'] + identity['last_name'])
      end
    end
  end

  user_one = User.find(698)

  ResearchMaster.find_by(creator_id: user_one.id).update_attribute(:creator_id, 709)

  user_one.destroy

  user_two = User.find(195)

  ResearchMaster.find_by(creator_id: user_two.id).update_attribute(:creator_id, 1464)

  user_two.destroy

  user_three = User.find(178)
  user_three.update_attribute(:email, 'nelsonjd@musc.edu')
  user_three.update_attribute(:net_id, 'jod9')
  user_three.update_attribute(:name, 'Joni Nelson')
end


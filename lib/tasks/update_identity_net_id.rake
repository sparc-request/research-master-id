task update_identity_net_id: :environment do
  ldap_search = LdapSearch.new
  User.all.each do |user|
    email = user.email
    user.update(net_id: ldap_search.net_id_query(email))
  end
end
task find_missing_netids: :environment do
  users = User.where(net_id: '[]')
  ldap_search = LdapSearch.new


  CSV.foreach(Rails.root.join('public', 'historical_data.csv'), headers: true) do |row|
    users.each do |user|
      if user.name.present?
        if user.name.include?(row['LastNameLegal'])
          user.update_attribute(:net_id, row['netID'])
        end
      end
    end
  end

  User.all.each do |user|
    net_id = ldap_search.net_id_query(user.email)
    user.update_attribute(:net_id, net_id)
  end

  users_without_name = User.where(name: nil)

  users_without_name.each do |user|
    net_id = user.net_id
    found_name = ldap_search.name_query(net_id)
    user.update_attribute(:name, found_name)
  end

end

task find_missing_pis: :environment do
  rms = ResearchMaster.where(pi_id: nil)

  ldap_search = LdapSearch.new

  rms.each do |rm|
    user = User.find_by(name: rm.pi_name)
    if user.present?
      rm.update_attribute(:pi_id, user.id)
    else
      search = ldap_search.info_query(rm.pi_name)
      if search.present?
        if User.exists?(email: search.first[1])
          found_user = User.find_by(email: search.first[1])
          rm.update_attribute(:pi_id, found_user.id)
        else
          pwd = Devise.friendly_token
          new_user = User.create_with(name: search.first[0], password: pwd, password_confirmation: pwd).find_or_create_by(email: search.first[1])
          rm.update_attribute(:pi_id, new_user.id)
        end
      end
    end
  end

  CSV.foreach(Rails.root.join('public', 'missing_pis_rmid.csv'), headers: true) do |row|
    rm = ResearchMaster.find(row['id'])
    user = User.find_or_create_by(net_id: row['PI Net ID'])
    rm.update_attribute(:pi_id, user.id)
  end

end

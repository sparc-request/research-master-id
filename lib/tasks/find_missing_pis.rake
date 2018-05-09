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
    new_pw = Devise.friendly_token
    user = User.create_with(name: row['pi_name'], password: new_pw, password_confirmation: new_pw, net_id: row['PI Net ID']).find_or_create_by(email: row['email'])
    rm.update_attribute(:pi_id, user.id)
  end

  CSV.foreach(Rails.root.join('public', 'missing_user_data.csv'), headers: true) do |row|
    user = User.find(row['id'])
    user.update_attribute(:net_id, row['Net ID'])
  end

  rm_to_fix = ResearchMaster.find(183)

  new_pw = Devise.friendly_token
  user_to_fix = User.create_with(name: 'Mithunan Maheswaranathan', password: new_pw, password_confirmation: new_pw, email: 'maheswar@musc.edu').find_or_create_by(net_id: 'mim39')

  rm_to_fix.update_attribute(:pi_id, user_to_fix.id)
end

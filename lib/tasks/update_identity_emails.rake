task update_identity_emails: :environment do

  ldap_search = LdapSearch.new

  User.all.each do |user|
    if user.id == 70 || user.id == 211
      user.destroy
    else
      uid = user.email.gsub('@musc.edu', '')
      user.update_attribute(:email, ldap_search.email_query(uid))
    end
  end
end

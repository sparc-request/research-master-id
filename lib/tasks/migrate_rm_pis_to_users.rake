task migrate_rm_pis_to_users: :environment do

  def progress_bar(count, increment)
    bar = "Progress: "
    bar += "=" * (count/increment)
    bar += "#{count/increment}0%\r"
  end
  def find_or_create_pi(email, name, password)
    if email.present?
      user = User.create_with(password: password, password_confirmation: password).
        find_or_create_by(email: email)
      user.update_attribute(:name, name)
      user
    end
  end


  rm_pis = ResearchMasterPi.all
  count = 1

  rm_pis.each do |rm_pi|
    pi = find_or_create_pi(rm_pi.email, rm_pi.name, Devise.friendly_token)
    rm = rm_pi.research_master
    rm.update_attribute(:pi, pi)
    print(progress_bar(count, rm_pis.count/10)) if count % (rm_pis.count/10)
    count += 1
  end
end


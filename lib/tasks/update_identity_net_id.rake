task update_identity_net_id: :environment do
  User.all.each do |user|
    user.update(net_id: user.email.gsub('@musc.edu', ''))
  end
end
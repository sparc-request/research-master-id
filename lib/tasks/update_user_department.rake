task update_user_department: :environment do

  coeus_api   = ENV.fetch("COEUS_API")
  prism_users = HTTParty.get("#{coeus_api}/prism", timeout: 500, headers: {'Content-Type' => 'application/json'})
  $users      = User.all

  prism_users.each do |user|
    if user_to_update = $users.detect{ |u| u.net_id == user['netid']
      user_to_update.update_attribute(:department, user['department'])
    end
  end
end
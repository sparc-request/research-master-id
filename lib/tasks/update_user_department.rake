task update_user_department: :environment do

  coeus_api = ENV.fetch("COEUS_API")
  prism_users = HTTParty.get("#{coeus_api}/prism", timeout: 500, headers: {'Content-Type' => 'application/json'})

  prism_users.each do |user|
    if User.exists?(net_id: user['netid'])
      user_to_update = User.find_by(net_id: user['netid'])
      user_to_update.update_attribute(:department_id, Department.find_or_create_by(name: user['department']).id)
    end
  end
end
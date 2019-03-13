task update_user_prism_boolean: :environment do

  coeus_api   = ENV.fetch("COEUS_API")
  prism_users = HTTParty.get("#{coeus_api}/prism", timeout: 500, headers: {'Content-Type' => 'application/json'})
  research_master_users = User.all

  research_master_users.each do |research_master_user|
    prism_user = prism_users.select {|user| user["netid"] == research_master_user.net_id }.first

    if prism_user
      research_master_user.update_attributes(current_prism_user: true)
    end
  end
end
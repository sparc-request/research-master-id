json.(@user_info) do |ui|
  json.name            ui[:name]
  json.email           ui[:email]
  json.netid           ui[:netid]
  json.first_name      ui[:first_name]
  json.last_name       ui[:last_name]
  json.middle_initial  ui[:middle_initial]
  json.pvid            ui[:pvid]
  json.department      ui[:department]
  json.interfolio_user ui[:interfolio_user]
  json.display_name    "#{ui[:name]} - #{ui[:email]}"
end

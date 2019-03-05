json.(@user_info) do |ui|
  json.name         ui[:name]
  json.email        ui[:email]
  json.department   ui[:department]
  json.prism_user   ui[:prism_user]
  json.display_name "#{ui[:name]} - #{ui[:email]}"
end

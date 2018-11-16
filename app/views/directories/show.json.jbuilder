json.(@user_info) do |ui|
  json.name ui[0]
  json.email ui[1]
  json.department ui[2]
  json.display_name "#{ui[0]} - #{ui[1]}"
end

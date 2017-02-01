json.(@user_info) do |ui|
  json.name ui[0]
  json.email ui[1]
end

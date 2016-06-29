json.(@identities) do |identity|
  json.id identity.id
  json.full_name identity.full_name
end

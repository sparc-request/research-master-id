json.array! @validated_research_masters do |rm|
  json.short_title rm.short_title
  json.long_title rm.long_title
  json.pro_number Protocol.find(rm.eirb_protocol_id).eirb_id
end

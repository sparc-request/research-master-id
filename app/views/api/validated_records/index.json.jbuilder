json.array! @validated_research_masters do |rm|
  json.id                       rm.id
  json.short_title              rm.short_title
  json.long_title               rm.long_title
  json.pro_number               rm.eirb_protocol.eirb_id
  json.date_initially_approved  rm.eirb_protocol.date_initially_approved
  json.date_approved            rm.eirb_protocol.date_approved
  json.date_expiration          rm.eirb_protocol.date_expiration
end

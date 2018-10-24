json.array! @validated_research_masters do |rm|
  json.id                       rm.id
  json.short_title              rm.short_title
  json.long_title               rm.long_title
  json.coeus_project_numbers    rm.coeus_protocols.try(:pluck, :coeus_project_id).try(:compact)
  json.eirb_pro_number          rm.eirb_protocol.try(:eirb_id)
  json.date_initially_approved  rm.eirb_protocol.try(:date_initially_approved)
  json.date_approved            rm.eirb_protocol.try(:date_approved)
  json.date_expiration          rm.eirb_protocol.try(:date_expiration)
end

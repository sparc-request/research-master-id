json.array! @research_masters do |rm|
  json.id                       rm.id
  json.short_title              rm.short_title
  json.long_title               rm.long_title
  json.coeus_project_numbers    rm.coeus_protocols.try(:pluck, :coeus_project_id).try(:compact)
  json.eirb_validated           rm.eirb_validated
  json.eirb_pro_number          rm.eirb_protocol.try(:eirb_id)
  json.date_initially_approved  rm.eirb_protocol.try(:date_initially_approved)
  json.date_approved            rm.eirb_protocol.try(:date_approved)
  json.date_expiration          rm.eirb_protocol.try(:date_expiration)
  json.principal_investigator do
    json.first_name rm.pi.first_name
    json.last_name  rm.pi.last_name
    json.email      rm.pi.email
    json.net_id     rm.pi.net_id
    json.department rm.pi.department
  end
end

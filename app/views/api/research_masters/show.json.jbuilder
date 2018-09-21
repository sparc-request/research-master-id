json.id                       @research_master.id
json.short_title              @research_master.short_title
json.long_title               @research_master.long_title
json.eirb_pro_number          @research_master.eirb_protocol.try(:eirb_id)
json.date_initially_approved  @research_master.eirb_protocol.try(:date_initially_approved).try(:strftime, "%m/%d/%Y")
json.date_approved            @research_master.eirb_protocol.try(:date_approved).try(:strftime, "%m/%d/%Y")
json.date_expiration          @research_master.eirb_protocol.try(:date_expiration).try(:strftime, "%m/%d/%Y")

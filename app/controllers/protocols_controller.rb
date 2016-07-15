class ProtocolsController < ApplicationController
  def index
    associated_ids = AssociatedRecord.associated_protocol_ids
    get_protocols = HTTParty.get('http://localhost:3000/protocols')
    protocols_array = JSON.parse(get_protocols.body)
    get_eirb_studies = HTTParty.get('http://localhost:5000/studies.json')
    eirb_studies_array = JSON.parse(get_eirb_studies.body)

    protocols_hash = Hash[protocols_array.each_slice(2).to_a]

    eirb_hash = Hash[eirb_studies_array.each_slice(2).to_a]

    entire_protocol_hash = protocols_hash.merge(eirb_hash)

    gon.protocols = entire_protocol_hash.reject { |k, v| associated_ids.include?(k['id']) }

    @protocols = gon.protocols

    respond_to do |format|
      format.html
    end
  end
end

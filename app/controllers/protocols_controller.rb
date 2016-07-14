class ProtocolsController < ApplicationController
  def index
    associated_ids = AssociatedRecord.associated_protocol_ids
    @protocols = HTTParty.get('http://localhost:3000/protocols')
    @q = @protocols.reject { |k, v| associated_ids.include?(k['id']) }
    respond_to do |format|
      format.html
    end
  end
end

class ProtocolsController < ApplicationController
  def index
    associated_ids = AssociatedRecord.associated_protocol_ids
    protocols = HTTParty.get('http://localhost:3000/protocols')
    gon.protocols = protocols.reject { |k, v| associated_ids.include?(k['id']) }
    if params[:search]
      @protocols = params[:data]
    else
      @protocols = gon.protocols
    end
    respond_to do |format|
      format.html
    end
  end
end

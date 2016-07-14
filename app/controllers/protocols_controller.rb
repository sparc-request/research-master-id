class ProtocolsController < ApplicationController
  def index
    associated_ids = AssociatedRecord.associated_protocol_ids
    @q = Protocol.where.not(id: associated_ids).ransack(params[:q])
    @protocols = HTTParty.get('http://localhost:3000/protocols')
    respond_to do |format|
      format.html
    end
  end
end

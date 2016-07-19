class ProtocolsController < ApplicationController
  def index
    associated_ids = AssociatedRecord.associated_protocol_ids
    @q = Protocol.includes(:primary_pi).ransack(params[:q])
    @protocols = @q.result.includes(:primary_pi).where.not(id: associated_ids)
    respond_to do |format|
      format.html
    end
  end
end


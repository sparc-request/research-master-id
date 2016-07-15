class ProtocolsController < ApplicationController
  def index
    associated_ids = AssociatedRecord.associated_protocol_ids
    @q = Protocol.where.not(id: associated_ids).ransack(params[:q])
    @protocols = @q.result(distinct: true)
    respond_to do |format|
      format.html
    end
  end
end


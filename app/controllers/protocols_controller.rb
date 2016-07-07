class ProtocolsController < ApplicationController
  def index
    @q = Protocol.ransack(params[:q])
    associated_ids = AssociatedRecord.associated_protocol_ids
    @protocols = @q.result(distinct: true).includes(:project_roles => :identity).limit(10).reject{ |x| associated_ids.include?(x.id) }
    respond_to do |format|
      format.html
    end
  end
end

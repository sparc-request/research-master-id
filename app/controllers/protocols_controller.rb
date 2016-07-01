class ProtocolsController < ApplicationController
  def index
    @q = Protocol.ransack(params[:q])
    @protocols = @q.result(distinct: true).includes(:project_roles => :identity).limit(10)
    respond_to do |format|
      format.html
    end
  end
end

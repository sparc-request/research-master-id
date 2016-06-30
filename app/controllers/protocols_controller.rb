class ProtocolsController < ApplicationController
  def index
    @q = Protocol.ransack(params[:q])
    @protocols = @q.result(distinct: true)
    respond_to do |format|
      format.html      
    end
  end
end

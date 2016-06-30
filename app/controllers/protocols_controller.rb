class ProtocolsController < ApplicationController
  def index
    @q = Protocol.ransack(params[:q])
    @protocols = @q.result(distinct: true)
    respond_to do |format|
      format.html
      format.json { render json: @protocols }
    end
  end

  def search
    index
    render action: 'index'
  end
end

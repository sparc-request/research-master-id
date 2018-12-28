class Api::ProtocolsController < ApplicationController
  def index
    respond_to do |format|
      format.json {
        if params[:type] && ['SPARC', 'EIRB', 'COEUS'].include?(params[:type])
          render json: Protocol.where(type: params[:type]).to_json
        else
          render json: Protocool.all.to_json
        end
      }
    end
  end
end

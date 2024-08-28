class Admin::ResearchMastersController < ApplicationController
  before_action :set_research_master, only: [:show, :edit, :update, :destroy]

  def index
    @q = ResearchMaster.ransack(params[:q])
    @research_masters = @q.result.page(params[:page]).per(25)
    respond_to do |format|
      format.html
      format.json { render json: @research_masters }
    end
  end

  def show
    research_master = ResearchMaster.find(params[:id])
      if research_master.sparc_protocol_id?
        @sparc_protocol = Protocol.find(research_master.sparc_protocol_id)
      end
      if research_master.eirb_protocol_id?
        @eirb_protocol = Protocol.find(research_master.eirb_protocol_id)
      end
    @coeus_records = research_master.coeus_protocols
    @cayuse_records = research_master.cayuse_protocols
    respond_to do |format|
      format.js { render 'admin/research_masters/show' }
    end
  end

  private

  def set_research_master
    @research_master = ResearchMaster.find(params[:id])
  end
end

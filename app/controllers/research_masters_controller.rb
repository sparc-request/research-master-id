class ResearchMastersController < ApplicationController
  layout 'main'

  def index
    @q = ResearchMaster.ransack(params[:q])
    @research_masters = @q.result(distinct: true)
    respond_to do |format|
      format.html
    end
  end

  def show
    research_master = ResearchMaster.find(params[:id])
    associated_record = research_master.associated_record
    if associated_record.sparc_id?
      @sparc_protocol = Protocol.find(associated_record.sparc_id)
    end
    if associated_record.eirb_id?
      @eirb_protocol = Protocol.find(associated_record.eirb_id)
    end
    respond_to do |format|
      format.js
    end
  end

  def new
    @research_master = ResearchMaster.new
    @research_master.build_associated_record
    respond_to do |format|
      format.js
    end
  end

  def create
    @q = ResearchMaster.ransack(params[:q])
    @research_masters = @q.result(distinct: true)
    @research_master = ResearchMaster.new(research_master_params)
    @research_master.user = current_user
    respond_to do |format|
      if @research_master.save
        format.js
      else
        format.json { render json: { error: @research_master.errors }, status: 400 }
      end
    end
  end

  def destroy
    @research_master = ResearchMaster.find(params[:id])
    @research_master.destroy
  end

  private

  def research_master_params
    params.require(:research_master).permit!
  end
end

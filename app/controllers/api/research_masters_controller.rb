class Api::ResearchMastersController < Api::BaseController

  def index
    @research_masters = ResearchMaster.all
    respond_to do |format|
      format.json { render json: @research_masters }
    end
  end

  def show
    @research_master = ResearchMaster.find(params[:id])
    respond_to do |format|
      format.json { render json: @research_master }
    end
  end
end


class Api::ResearchMastersController < Api::BaseController

  def index
    @research_masters = ResearchMaster.eager_load(:protocols).all

    respond_to do |format|
      format.json
    end
  end

  def show
    @research_master = ResearchMaster.find(params[:id])

    respond_to do |format|
      format.json
    end
  end
end


class Api::ValidatedRecordsController < Api::BaseController

  def index
    @validated_research_masters = ResearchMaster.validated
    respond_to do |format|
      format.json { render json: @validated_research_masters }
    end
  end
end


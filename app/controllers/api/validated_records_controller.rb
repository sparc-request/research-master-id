class Api::ValidatedRecordsController < Api::BaseController

  def index
    @validated_research_masters = ResearchMaster.eager_load(:eirb_protocol, :coeus_protocols).validated
    respond_to do |format|
      format.json
    end
  end
end


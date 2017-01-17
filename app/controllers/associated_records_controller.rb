class AssociatedRecordsController < ApplicationController

  def destroy
    @research_masters = ResearchMaster.all
    @research_master = ResearchMaster.find(params[:research_master_id])
    @associated_record = @research_master.associated_record
    respond_to do |format|
      if @associated_record.destroy
        format.js
      end
    end
  end
end

class ResearchMastersController < ApplicationController

  def index
    @q = ResearchMaster.ransack(params[:q])
    @research_masters = @q.result(distinct: true)
    respond_to do |format|
      format.html
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
    @research_master = ResearchMaster.new(research_master_params)
    @research_master.user = current_user
    if @research_master.save
      redirect_to protocols_path
    else
      render :new
    end
  end

  private

  def research_master_params
    params.require(:research_master).permit!
  end
end

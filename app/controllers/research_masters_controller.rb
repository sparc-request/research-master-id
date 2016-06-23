class ResearchMastersController < ApplicationController

  def index
    @research_masters = current_user.research_masters
    respond_to do |format|
      format.html
      format.json { render json: @research_masters }
    end
  end

  def new
    @research_master = ResearchMaster.new
    respond_to do |format|
      format.js
    end
  end
end

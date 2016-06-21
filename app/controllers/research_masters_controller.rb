class ResearchMastersController < ApplicationController

  def index
    @research_masters = current_user.research_masters
    respond_to do |format|
      format.html
      format.json { render json: @research_masters }
    end
  end
end

class Api::ResearchMastersController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :restrict_access

  def index
    @research_masters = ResearchMaster.all
    respond_to do |format|
      format.json { render json: @research_masters }
    end
  end

  private

  def restrict_access
    authenticate_or_request_with_http_token do |token, options|
      ApiKey.exists?(access_token: token)
    end
  end
end

class PrimaryPisController < ApplicationController

  def index
    @primary_pis = PrimaryPi.all
    respond_to do |format|
      format.json
    end
  end
end

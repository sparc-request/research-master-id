class PrimaryPisController < ApplicationController

  def index
    @primary_pis = PrimaryPi.all.group(:name)
    respond_to do |format|
      format.json
    end
  end
end

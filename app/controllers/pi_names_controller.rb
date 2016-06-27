class PiNamesController < ApplicationController
  def index
    @identities = Identity.primary_pi_list
    respond_to do |format|
      format.json
    end
  end
end


class Api::ApiKeysController < ApplicationController
  before_action do
    redirect_to new_user_session_path unless current_user.developer?
  end

  def new
    respond_to do |format|
      format.html
    end
  end

  def create
    @api_key = ApiKey.create!
    respond_to do |format|
      format.js
    end
  end
end

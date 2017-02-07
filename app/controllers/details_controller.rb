class DetailsController < ApplicationController
  skip_before_action :authenticate_user!
  protect_from_forgery except: :show

  def show
  end
end


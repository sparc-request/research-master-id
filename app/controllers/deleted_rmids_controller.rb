class DeletedRmidsController < ApplicationController
  layout 'main'
  protect_from_forgery

  def index
    @deleted_rmids = DeletedRmid.all
    respond_to do |format|
      format.html
    end
  end
end
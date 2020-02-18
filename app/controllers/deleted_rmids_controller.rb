class DeletedRmidsController < ApplicationController
  layout 'main'
  protect_from_forgery

  def index
    @q = DeletedRmid.ransack(params[:q])
    @deleted_rmids = @q.result
    respond_to do |format|
      format.html
    end
  end
end

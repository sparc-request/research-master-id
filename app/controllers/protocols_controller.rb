class ProtocolsController < ApplicationController
  before_action :must_be_admin
  layout 'main'

  def index
    rm = ResearchMaster.all
    associated_ids = (rm.pluck(:sparc_protocol_id) + rm.pluck(:eirb_protocol_id)).compact!
    @q = Protocol.includes(:primary_pi).ransack(params[:q])
    @protocols = @q.result.includes(:primary_pi).where.not(id: associated_ids)
    respond_to do |format|
      format.html
    end
  end

  private

  def must_be_admin
    unless current_user && current_user.admin?
      redirect_to root_path, alert: "You must have administrative rights to view/associate Protocols"
    end
  end
end


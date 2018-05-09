class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def new
    @research_master = ResearchMaster.find(params[:research_master_id])
    @notification = Notification.new
    respond_to do |format|
      format.js
    end
  end

  def create
    @research_master = ResearchMaster.find(params[:research_master_id])
    @notification = Notification.new(notification_params)
    if @notification.valid?
      AdminNotifierMailer.admin_email(@research_master, @notification.message, current_user.email).deliver
    end
    respond_to do |format|
      format.js
    end
  end

  private

  def notification_params
    params.require(:notification).permit(:message)
  end
end

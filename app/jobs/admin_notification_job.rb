class AdminNotificationJob < ApplicationJob
  queue_as :default

  def perform(research_master_id, message, admin)
    email = AdminNotification.new(research_master_id, message, admin)
    email.admin_notifier
  end
end

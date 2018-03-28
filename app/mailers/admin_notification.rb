class AdminNotification < ActionMailer::Base

  def admin_notifier(research_master_id, message, admin)
    @message = message
    @research_master_id = research_master_id
    mail(
      to: ENV.fetch('ENVIRONMENT') == 'staging' ? 'sparcrequest@gmail.com' : [research_master_id.creator.email, research_master_id.pi.nil? ? '' : research_master_id.pi.email],
      subject: "Research Master ID #{rm_id.id} - Message from Admin",
      from: admin
    )
  end
end

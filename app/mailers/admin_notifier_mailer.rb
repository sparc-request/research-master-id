class AdminNotifierMailer < ApplicationMailer

  def admin_email(research_master_id, message, admin)
    @message = message
    @research_master_id = research_master_id
    address = ENV.fetch('ENVIRONMENT') == 'staging' ? 'sparcrequest@gmail.com' : [research_master_id.creator.email, research_master_id.pi.nil? ? '' : research_master_id.pi.email]
    mail(
      to: address,
      subject: "Research Master ID #{research_master_id.id} - Message from Admin",
      from: admin
    )
  end
end


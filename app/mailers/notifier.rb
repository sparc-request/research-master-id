class Notifier < ActionMailer::Base

  def success(recipient, rm_pi, rm_id)
    @rm_pi = rm_pi || NullUser.new
    @rm_id = rm_id
    @url = ENV.fetch('RMID_LINK')
    address = ENV.fetch('ENVIRONMENT') == 'staging' ? 'sparcrequest@gmail.com' : recipient
    mail(
      to: address,
      subject: "Research Master Record Successfully Created (RMID: #{rm_id.id})",
      from: 'no-reply@rmid.musc.edu'
    )
  end
end

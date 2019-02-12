class Notifier < ActionMailer::Base

  def success(recipient, pi, rm_id)
    @pi = pi || NullUser.new
    @rm_id = rm_id
    @url = ENV.fetch('RMID_LINK')
    address = ENV.fetch('ENVIRONMENT') == 'staging' ? 'sparcrequest@gmail.com' : recipient
    mail(
      to: address,
      subject: "Research Master Record Successfully Created (RMID: #{rm_id.id} - #{recipient})",
      from: 'donotreply@musc.edu'
    )
  end

  def delayed_jobs_down(recipients, prev_status, curr_status)
    @prev_status = prev_status
    @curr_status = curr_status

    mail(
      to: recipients,
      subject: "[Research Master ID] Delayed Jobs is down",
      from: 'donotreply@musc.edu'
    )
  end
end

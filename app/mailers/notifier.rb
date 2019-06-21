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

  def removed(deleted_rmid)
    @deleted_rmid = deleted_rmid
    @pi = User.find(@deleted_rmid.pi_id)
    @creator = User.find(@deleted_rmid.creator_id)
    @remover = User.find(@deleted_rmid.user_id)
    combined_emails = (@pi.email == @creator.email ? @pi.email : [@pi.email, @creator.email])
    address = ENV.fetch('ENVIRONMENT') == 'staging' ? 'sparcrequest@gmail.com' : combined_emails
    mail(
      to: address,
      subject: "Research Master Record Removed (RMID: #{@deleted_rmid.original_id}",
      from: 'donotreply@musc.edu'
    )
  end
end

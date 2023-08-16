class PiUpdateMailer < ApplicationMailer

  def ldap_missing_email(missing_pis, emails)
    @missing_pis = missing_pis
    @environment = ENV.fetch('ENVIRONMENT')
    mail(
      to: emails,
      subject: "RMID PI Info Update Failed",
      from: 'donotreply@musc.edu'
    )
  end
end
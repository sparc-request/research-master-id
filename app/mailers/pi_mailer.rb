class PiMailer < ApplicationMailer
  default from: 'donotreply@musc.edu'

  def notify_pis(rm, existing_pi, current_pi)
    @rm = rm
    @existing_pi = existing_pi
    @current_pi = current_pi
    address = ENV.fetch('ENVIRONMENT') == 'staging' ? 'sparcrequest@gmail.com' : [existing_pi.email, current_pi.email]
    mail to: address, subject: "(RMID - #{rm.id}) Research Master ID Primary PI Record Update"
  end
end

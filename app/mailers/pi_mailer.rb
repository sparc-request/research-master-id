class PiMailer < ApplicationMailer
  default from: 'donotreply@musc.edu'

  def notify_pis(rm, existing_pi, current_pi, creator)
    @rm = rm
    @existing_pi = existing_pi
    @current_pi = current_pi
    @creator = creator
    if @current_pi.id == @creator.id
      address = ENV.fetch('ENVIRONMENT') == 'staging' ? 'sparcrequest@gmail.com' : [existing_pi.email, current_pi.email]
    else
      address = ENV.fetch('ENVIRONMENT') == 'staging' ? 'sparcrequest@gmail.com' : [existing_pi.email, current_pi.email, creator.email]
    end
    mail to: address, subject: "(RMID - #{rm.id}) Research Master ID Primary PI Record Update"
  end
end

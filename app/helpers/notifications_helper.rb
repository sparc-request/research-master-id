module NotificationsHelper

  def notification_email_recipients(creator, pi)
    if pi.nil?
      pi = ''
    end
    if creator.email == pi.email
      "#{creator.email}"
    else
      "#{creator.email}, #{pi.email}"
    end
  end
end

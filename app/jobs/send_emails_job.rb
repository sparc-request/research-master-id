class SendEmailsJob < ApplicationJob
  queue_as :default

  def perform(pi, creator_email, record)
    rm_notifier = ResearchMasterNotifier.new(pi, creator_email, record)
    rm_notifier.send_mail
  end
end

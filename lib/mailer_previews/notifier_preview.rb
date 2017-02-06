class NotifierPreview < ActionMailer::Preview

  def success
    Notifier.success(User.first.email, ResearchMasterPi.first, ResearchMaster.first)
  end
end

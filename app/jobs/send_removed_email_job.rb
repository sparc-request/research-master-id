class SendRemovedEmailJob < ApplicationJob
  queue_as :default

  def perform(deleted_rmid)
    Notifier.removed(deleted_rmid).deliver_now
  end
end

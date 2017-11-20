class ResearchMasterNotifier

  def initialize(pi, owner_email, rm_id)
    @pi = pi
    @owner_email = owner_email || NullUser.new.email
    @rm_id = rm_id
  end

  def send_mail
    if @pi.nil?
      send_one
    else
      send_multiple
    end
  end

  private

  def send_one
    Notifier.success(
      @owner_email,
      @pi,
      @rm_id
    ).deliver_now
  end

  def send_multiple
    recipients.each do |recipient|
      Notifier.success(
        recipient,
        @pi,
        @rm_id
      ).deliver_now
    end
  end

  def recipients
    [@pi.email, @owner_email]
  end
end


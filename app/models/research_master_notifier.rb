class ResearchMasterNotifier

  def initialize(rm_pi, owner_email, rm_id)
    @rm_pi = rm_pi
    @owner_email = owner_email || NullUser.new.email
    @rm_id = rm_id
  end

  def send_mail
    if @rm_pi.nil? || same_email
      send_one
    else
      send_multiple
    end
  end

  private

  def send_one
    Notifier.success(
      @owner_email,
      @rm_pi,
      @rm_id
    ).deliver_later
  end

  def send_multiple
    recipients.each do |recipient|
      Notifier.success(
        recipient,
        @rm_pi,
        @rm_id
      ).deliver_later
    end
  end

  def same_email
    @rm_pi.email == @owner_email
  end

  def recipients
    [@rm_pi.email, @owner_email]
  end
end


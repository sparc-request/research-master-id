require 'rails_helper'

describe ResearchMasterNotifier do
  before { ActionMailer::Base.deliveries = [] }

  describe '#send_mail' do
    it 'should send only one email if the addresses are the same' do
      user = create(:user)
      rm_id = create(:research_master,
                     pi_name: 'willy',
                     department: 'dept',
                     long_title: 'long',
                     short_title: 'short',
                     funding_source: 'funding',
                     user: user)
      owner_email = user.email
      pi = create(:research_master_pi, email: user.email)
      rm_notifier = ResearchMasterNotifier.new(pi, owner_email, rm_id)

      rm_notifier.send_mail

      expect(ActionMailer::Base.deliveries.count).to eq(1)
    end

    it 'should still send an email if rm_pi is nil' do
      user = create(:user)
      rm_id = create(:research_master,
                     pi_name: 'willy',
                     department: 'dept',
                     long_title: 'long',
                     short_title: 'short',
                     funding_source: 'funding',
                     user: user
                    )
      owner_email = user.email
      rm_notifier = ResearchMasterNotifier.new(nil, owner_email, rm_id)

      rm_notifier.send_mail

      expect(ActionMailer::Base.deliveries.count).to eq(1)
    end

    it 'should still send an email if user email is nil' do
      user = create(:user)
      rm_id = create(:research_master,
                     pi_name: 'willy',
                     department: 'dept',
                     long_title: 'long',
                     short_title: 'short',
                     funding_source: 'funding',
                     user: user
                    )
      rm_notifier = ResearchMasterNotifier.new(nil, nil, rm_id)

      rm_notifier.send_mail

      expect(ActionMailer::Base.deliveries.count).to eq(1)
    end

    it 'should send two emails if different' do
      user = create(:user)
      rm_id = create(:research_master,
                     pi_name: 'willy',
                     department: 'dept',
                     long_title: 'long',
                     short_title: 'short',
                     funding_source: 'funding',
                     user: user)
      owner_email = user.email
      pi = create(:research_master_pi, research_master: rm_id)
      rm_notifier = ResearchMasterNotifier.new(pi, owner_email, rm_id)

      rm_notifier.send_mail

      expect(ActionMailer::Base.deliveries.count).to eq(2)
    end
  end
end

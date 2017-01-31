require 'rails_helper'

RSpec.describe Notifier do

  describe '#success' do

    it 'should have two recipients' do
      ENV['ENVIRONMENT'] = 'production'
      owner = create(:user)
      rm_id = create(:research_master, user: owner)
      rm_pi = create(:research_master_pi, research_master: rm_id)

      result = Notifier.success(owner.email, rm_pi, rm_id)

      expect(result.to).to eq [owner.email]
    end

    it 'should have the correct subject' do
      owner = create(:user)
      rm_id = create(:research_master, user: owner)
      rm_pi = create(:research_master_pi, research_master: rm_id)

      result = Notifier.success(owner.email, rm_pi, rm_id)

      expect(result.subject).to eq "Research Master Record Successfully Created (RMID: #{rm_id.id})"
    end

    it 'it should be from no-reply@rmid.musc.edu' do
      owner = create(:user, email: 'pi@email.com')
      rm_id = create(:research_master, user: owner)
      rm_pi = create(:research_master_pi, research_master: rm_id)

      result = Notifier.success(owner.email, rm_pi, rm_id)

      expect(result.from).to eq ['no-reply@rmid.musc.edu']
    end

    it 'should send to gmail if env is staging' do
      ENV['ENVIRONMENT'] = 'staging'
      owner = create(:user, email: 'pi@email.com')
      rm_id = create(:research_master, user: owner)
      rm_pi = create(:research_master_pi, research_master: rm_id)

      result = Notifier.success(owner.email, rm_pi, rm_id)

      expect(result.to).to eq ['sparcrequest@gmail.com']
    end

    it 'carry on if production' do
      ENV['ENVIRONMENT'] = 'production'
      owner = create(:user, email: 'pi@email.com')
      rm_id = create(:research_master, user: owner)
      rm_pi = create(:research_master_pi, research_master: rm_id)

      result = Notifier.success(owner.email, rm_pi, rm_id)

      expect(result.to).to eq [owner.email]
    end
  end
end


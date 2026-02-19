require 'rails_helper'

class UpdateFromEirbDbSpecHelper
  def update_rm(remote_study, local_protocol)
    if (rm = $research_masters.detect{ |rm| rm.id == remote_study['rmid'].to_i }) && (remote_study['project_status'] != 'Withdrawn')
      eirb_protocol_changed = rm.eirb_protocol_id != local_protocol.id
      rm.eirb_protocol_id       = local_protocol.id
      rm.eirb_association_date  = DateTime.current if eirb_protocol_changed
      rm.eirb_original_association_date = DateTime.current unless rm.eirb_original_association_date

      if validated_state_checker($validated_states, remote_study['project_status'])
        rm.eirb_validated = true
        rm.short_title    = remote_study['short_title']
        rm.long_title     = remote_study['title']

        update_pi(rm, remote_study, local_protocol)
      else
        rm.eirb_validated = false
      end

      if rm.changed?
        rm.save(validate: false)
      end
    end
  end
  def update_pi(rm, remote_study, local_protocol)
    nil
  end

  def update_pi(rm, study, protocol)
    if protocol.primary_pi_id.present? && rm.pi_id != protocol.primary_pi_id

      if rm.previous_pi_id.nil? && rm.original_pi_id.nil?
        rm.original_pi_id = rm.pi_id
      end

      rm.previous_pi_id = rm.pi_id
      rm.pi_id = protocol.primary_pi_id
      rm.pi_change_date = DateTime.current

      begin
        ResearchMaster.auditing_enabled = true
        saved = rm.save(validate: false)
      ensure
        ResearchMaster.auditing_enabled = false
      end

      if saved
        begin
          existing = User.find_by(id: rm.previous_pi_id)
          current  = User.find_by(id: rm.pi_id)
          creator  = User.find_by(id: rm.creator_id)
          if existing && current && creator
            if ENV['SUPPRESS_PI_MAILER'] != 'true'
              PiMailer.notify_pis(rm, existing, current, creator).deliver_now
            end
          end
        rescue => e
          log "--- *Error sending PI mailer: #{e.message}*"
        end
        return true
      end
    end
    return false
  end

  def restore_original_pi(no_longer_linked_to_validated_eirb_study_ids)
    ResearchMaster.where(id: no_longer_linked_to_validated_eirb_study_ids).each do |rm|
      next unless rm.original_pi_id.present? && rm.pi_id != rm.original_pi_id

      current_pi = User.find_by(id: rm.pi_id)
      original_pi = User.find_by(id: rm.original_pi_id)
      creator = User.find_by(id: rm.creator_id)

      rm.previous_pi_id = rm.pi_id
      rm.pi_id = rm.original_pi_id
      rm.pi_change_date = DateTime.current

      if rm.save(validate: false)
        if current_pi && original_pi && creator
          PiMailer.notify_pis_on_restore(
            rm,
            current_pi,
            original_pi,
            creator
          ).deliver_now
        end
      end
    end
  end
end

RSpec.describe 'update_rm method' do
  subject(:task_helper) { UpdateFromEirbDbSpecHelper.new }
  let!(:pi) { create(:user) }
  let!(:rm) { create(:research_master, pi: pi, eirb_validated: false) }
  let!(:protocol) { create(:protocol, type: 'EIRB', primary_pi_id: pi.id) }
  let(:study) do
    {
      'rmid' => rm.id.to_s,
      'short_title' => 'Short EIRB Title',
      'title' => 'Long EIRB Title',
      'project_status' => 'Approved'
    }
  end
  before do
    $research_masters = [rm]
    $validated_states = ['Approved']

    allow(rm).to receive(:save).with(validate: false).and_return(true)
    allow(task_helper).to receive(:update_pi).and_return(nil)
  end

  context 'when the eirb study has a project_status in $validated_states' do
    before do
      def task_helper.validated_state_checker(*args)
        true
      end
    end
    it 'it updates the rm attrs' do
      task_helper.update_rm(study, protocol)

      expect(rm.eirb_protocol_id).to eq(protocol.id)
      expect(rm.eirb_validated).to be true
      expect(rm.short_title).to eq(study['short_title'])
      expect(rm.long_title).to eq(study['title'])
    end
  end
  context 'when the eirb study has a project_status not in $validated_states' do
    let!(:rm) { create(:research_master, pi: pi, eirb_validated: true) }

    before do
      def task_helper.validated_state_checker(*args)
        false
      end
    end

    it 'updates eirb_validated to false' do
      task_helper.update_rm(study, protocol)
      expect(rm.eirb_protocol_id).to eq(protocol.id)
      expect(rm.eirb_validated).to be false
    end

    it 'it does not update the rm attrs' do
      task_helper.update_rm(study, protocol)

      expect(rm.eirb_protocol_id).to eq(protocol.id)
      expect(rm.eirb_validated).to be false
    end
  end
end

RSpec.describe 'update_pi method' do
  subject(:task_helper) { UpdateFromEirbDbSpecHelper.new }
  let!(:previous_pi) { create(:user) }
  let!(:current_pi) { create(:user) }
  let!(:creator) { create(:user) }
  let!(:rm) { create(:research_master, pi: previous_pi, creator: creator) }
  let!(:protocol) { create(:protocol, primary_pi_id: current_pi.id) }
  let(:study) { { 'rmid' => rm.id.to_s }}
  before do
    allow(rm).to receive(:save).with(validate: false).and_return(true)
    allow(User).to receive(:find_by).with(id: previous_pi.id).and_return(previous_pi)
    allow(User).to receive(:find_by).with(id: current_pi.id).and_return(current_pi)
    allow(User).to receive(:find_by).with(id: creator.id).and_return(creator)
    allow(PiMailer).to receive_message_chain(:notify_pis, :deliver_now)
    allow(ResearchMaster).to receive(:auditing_enabled=)
  end
  context 'when the local protocol has a different pi than the rm' do
    it 'updates the rm pi and sends an email' do
      expect(task_helper.update_pi(rm, study, protocol)).to be true
      expect(rm.pi_id).to eq(current_pi.id)
      expect(rm.previous_pi_id).to eq(previous_pi.id)
      expect(rm.original_pi_id).to eq(previous_pi.id)
      expect(rm.pi_change_date).to be_present
    end
  end
  context 'when the local protocol has the same pi as the rm' do
    let!(:protocol) { create(:protocol, primary_pi_id: previous_pi.id) }
    it 'does not update the rm pi' do
      expect(task_helper.update_pi(rm, study, protocol)).to be false
      expect(rm.pi_id).to eq(previous_pi.id)
      expect(rm.previous_pi_id).to be_nil
      expect(rm.original_pi_id).to be_nil
      expect(rm.pi_change_date).to be_nil
    end
  end
end

RSpec.describe 'restore_original_pi method' do
  subject(:task_helper) { UpdateFromEirbDbSpecHelper.new }
  let!(:current_pi) { create(:user, first_name: 'Current', last_name: 'PI', email: 'current_pi@test.com', password: "password") }
  let!(:original_pi) { create(:user, first_name: 'Original', last_name: 'PI', email: 'original_pi@test.com', password: "password") }
  let!(:creator) { create(:user, first_name: 'Creator', last_name: 'User', email: 'creator1@test.com', password: "password") }

  let!(:rm_to_restore) do
    create(
      :research_master,
      pi_id: current_pi.id,
      original_pi_id: original_pi.id,
      creator_id: creator.id,
      long_title: 'long',
      short_title: 'short',
    )
  end
  let!(:pi_before_restore) { current_pi.id }

  before do
    allow(ResearchMaster).to receive(:where)
    .with(id: [rm_to_restore.id])
    .and_return([rm_to_restore])

    allow(User).to receive(:find_by).with(id: current_pi.id)
    .and_return(current_pi)
    allow(User).to receive(:find_by).with(id: original_pi.id)
    .and_return(original_pi)
    allow(User).to receive(:find_by).with(id: creator.id)
    .and_return(creator)
    allow(rm_to_restore).to receive(:save).with(validate: false).and_return(true)
    allow(PiMailer).to receive_message_chain(:notify_pis_on_restore, :deliver_now)
  end

  it 'updates the PI to the original PI' do
    task_helper.restore_original_pi([rm_to_restore.id])

    expect(rm_to_restore.pi_id).to eq(original_pi.id)
    expect(rm_to_restore.previous_pi_id).to eq(pi_before_restore)
  end

  it "sends a notification email that PI was restored" do
    task_helper.restore_original_pi([rm_to_restore.id])

    expect(PiMailer).to have_received(:notify_pis_on_restore).with(
      rm_to_restore, current_pi, original_pi, creator)
  end
end

require 'rails_helper'

class UpdateFromEirbDbSpecHelper
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

RSpec.describe 'restore_original_pi method' do
  subject(:task_helper) { UpdateFromEirbDbSpecHelper.new }
  let!(:current_pi) { User.create!(first_name: 'Current', last_name: 'PI', email: 'current_pi@test.com', password: "password") }
  let!(:original_pi) { User.create!(first_name: 'Original', last_name: 'PI', email: 'original_pi@test.com', password: "password") }
  let!(:creator) { User.create!(first_name: 'Creator', last_name: 'User', email: 'creator1@test.com', password: "password") }

  let!(:rm_to_restore) do
    ResearchMaster.create!(
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

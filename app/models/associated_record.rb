class AssociatedRecord < ActiveRecord::Base
  belongs_to :research_master

  def self.associated_protocol_ids
    all.pluck(:sparc_id)
  end

  def update_rm
    unless self.eirb_id.nil?
      eirb_id = self.eirb_id
      eirb_protocol = Protocol.find(eirb_id)
      if validated_states.include?(eirb_protocol.eirb_state)
        rm = self.research_master
        rm.update_attributes(short_title: eirb_protocol.short_title,
                            long_title: eirb_protocol.long_title,
                            eirb_validated: true
                            )
      end
    end
  end

  private

  def validated_states
    ['Acknowledged', 'Approved', 'Completed', 'Disapproved', 'Exempt Approved', 'Expired',  'Expired - Continuation in Progress', 'External IRB Review Archive', 'Not Human Subjects Research', 'Suspended', 'Terminated', 'Withdrawn']
  end
end

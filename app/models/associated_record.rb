class AssociatedRecord < ActiveRecord::Base
  belongs_to :research_master

  def self.associated_protocol_ids
    all.pluck(:sparc_id)
  end
end

class ResearchMaster < ActiveRecord::Base
  belongs_to :user
  has_one :associated_record
end

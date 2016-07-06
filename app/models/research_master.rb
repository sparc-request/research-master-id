class ResearchMaster < ActiveRecord::Base
  belongs_to :user
  has_one :associated_record

  accepts_nested_attributes_for :associated_record
end

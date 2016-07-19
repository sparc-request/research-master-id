class ResearchMaster < ActiveRecord::Base
  belongs_to :user
  has_one :associated_record, dependent: :destroy

  validates :pi_name, :department, :long_title, :short_title, :funding_source, presence: true

  accepts_nested_attributes_for :associated_record
end

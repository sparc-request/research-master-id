class ResearchMaster < ActiveRecord::Base
  belongs_to :user
  has_one :associated_record, dependent: :destroy

  validates :pi_name, :department, :long_title, :short_title, presence: true

  validates :pi_name,
    uniqueness: { scope: [:department, :long_title],
    message: 'There is an existing Research Master record with the same
    Department and Long Title' }

  validates :department,
    uniqueness: { scope: [:pi_name, :long_title],
    message: 'There is an existing Research Master record with the same PI Name
    and Long Title' }

  validates :long_title,
    uniqueness: { scope: [:pi_name, :department],
    message: 'There is an existing Research Master record with the same PI Name
    and Department' }

  accepts_nested_attributes_for :associated_record, allow_destroy: true,
    reject_if: proc { |att| att[:sparc_id].blank? && att[:eirb_id].blank? }

end

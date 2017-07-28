class ResearchMaster < ApplicationRecord
  belongs_to :user
  has_one :research_master_pi, dependent: :destroy

  validates :pi_name,
    :department,
    :long_title,
    :short_title,
    :funding_source,
    presence: true
  validates_length_of :short_title, maximum: 255

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

  validates_format_of :long_title, with: /^[a-zA-Z\d\s.%\/$*<>!@#^\[\]{};:"'?&()-_=+]*$/,
    message: 'Special characters are not allowed in the Long Title',
    multiline: true

  validates_format_of :short_title, with: /^[a-zA-Z\d\s.%\/$*<>!@#^\[\]{};:"'?&()-_=+]*$/,
    message: 'Special characters are not allowed in the Short Title',
    multiline: true

  def self.validated
    where(eirb_validated: true)
  end
end

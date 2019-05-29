class ResearchMaster < ApplicationRecord
  audited

  include SanitizedData
  sanitize_setter :long_title, :special_characters, :squish
  sanitize_setter :short_title, :special_characters, :squish

  belongs_to :creator, class_name: "User"
  belongs_to :pi, class_name: "User"
  belongs_to :sparc_protocol, class_name: :Protocol, optional: true
  belongs_to :eirb_protocol, class_name: :Protocol, optional: true

  has_many :research_master_coeus_relations
  has_many :coeus_protocols, through: :research_master_coeus_relations, source: :protocol

  paginates_per 50

  validates :long_title,
    :short_title,
    :funding_source,
    presence: true

  validates_length_of :short_title, maximum: 255

  validates :pi_id,
    uniqueness: { scope: [:long_title],
    message: 'There is an existing Research Master record with the same
    Long Title' }

  validates :long_title,
    uniqueness: { scope: [:pi_id],
    message: 'There is an existing Research Master record with the same PI Name' }

  #to-do: Do we still need these validations since we included SanitizedData?
  #validates_format_of :long_title, with: /^[a-zA-Z\d\s.%\/$*<>!@#^\[\]{};:"'?&()-_=+]*$/,
    #message: 'Special characters are not allowed in the Long Title',
    #multiline: true

  #validates_format_of :short_title, with: /^[a-zA-Z\d\s.%\/$*<>!@#^\[\]{};:"'?&()-_=+]*$/,
    #message: 'Special characters are not allowed in the Short Title',
    #multiline: true

  validates_presence_of :research_type

  def self.validated
    where(eirb_validated: true)
  end

  def has_attached_data?
    eirb_validated? or sparc_protocol_id? or coeus_protocols.any?
  end
end

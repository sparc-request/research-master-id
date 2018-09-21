class ResearchMaster < ApplicationRecord
  audited
  include SanitizedData
  sanitize_setter :long_title, :special_characters, :squish
  sanitize_setter :short_title, :special_characters, :squish
  belongs_to :creator, class_name: "User"
  belongs_to :pi, class_name: "User"
  has_many :research_master_coeus_relations
  has_many :protocols, through: :research_master_coeus_relations
  paginates_per 50

  validates :department,
    :long_title,
    :short_title,
    :funding_source,
    presence: true

  validates_length_of :short_title, maximum: 255

  validates :pi_id,
    uniqueness: { scope: [:department, :long_title],
    message: 'There is an existing Research Master record with the same
    Department and Long Title' }

  validates :department,
    uniqueness: { scope: [:pi_id, :long_title],
    message: 'There is an existing Research Master record with the same PI Name
    and Long Title' }

  validates :long_title,
    uniqueness: { scope: [:pi_id, :department],
    message: 'There is an existing Research Master record with the same PI Name
    and Department' }

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

  def eirb_protocol
    self.eirb_protocol_id && Protocol.find(self.eirb_protocol_id)
  end

  def clinical_research?
    ['clinical_research_billable', 'clinical_research_non_billable'].include?(self.research_type)
  end

  def to_json
    json = self.attributes

    if eirb_p = self.eirb_protocol
      json.merge!({
        pro_number:               eirb_p.eirb_id,
        date_initially_approved:  eirb_p.date_initially_approved.try(:strftime, "%m/%d/%Y"),
        date_approved:            eirb_p.date_approved.try(:strftime, "%m/%d/%Y"),
        date_expiration:          eirb_p.date_expiration.try(:strftime, "%m/%d/%Y")
      })
    end

    json
  end
end

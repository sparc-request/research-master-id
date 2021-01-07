# Copyright © 2020 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

class ResearchMaster < ApplicationRecord
  audited

  attr_accessor :search_term

  include SanitizedData
  sanitize_setter :long_title, :special_characters, :epic_special_characters, :squish
  sanitize_setter :short_title, :special_characters, :epic_special_characters, :squish

  belongs_to :creator, class_name: "User"
  belongs_to :pi, class_name: "User"
  belongs_to :sparc_protocol, class_name: :Protocol, optional: true
  belongs_to :eirb_protocol, class_name: :Protocol, optional: true

  has_many :research_master_coeus_relations
  has_many :coeus_protocols, through: :research_master_coeus_relations, source: :protocol

  has_many :research_master_cayuse_relations
  has_many :cayuse_protocols, through: :research_master_cayuse_relations, source: :protocol


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

  validates_presence_of :research_type

  def self.validated
    where(eirb_validated: true)
  end

  def has_attached_data?
    eirb_validated? or sparc_protocol_id? or coeus_protocols.any? or cayuse_protocols.any?
  end
end

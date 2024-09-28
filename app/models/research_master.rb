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

  include DateFormatHelper

  attr_accessor :search_term

  include SanitizedData
  sanitize_setter :long_title, :special_characters, :epic_special_characters, :squish
  sanitize_setter :short_title, :special_characters, :epic_special_characters, :squish

  belongs_to :creator, class_name: "User", foreign_key: "creator_id"
  belongs_to :pi, class_name: "User", foreign_key: "pi_id"
  belongs_to :sparc_protocol, class_name: :Protocol, foreign_key: "sparc_protocol_id", optional: true
  belongs_to :eirb_protocol, class_name: :Protocol, foreign_key: "eirb_protocol_id", optional: true

  has_many :research_master_coeus_relations
  has_many :coeus_protocols, through: :research_master_coeus_relations, source: :protocol

  has_many :research_master_cayuse_relations
  has_many :cayuse_protocols, through: :research_master_cayuse_relations, source: :protocol


  paginates_per 50

  validates :long_title, :short_title, presence: true

  validates :short_title, length: { maximum: 255 }

  validates :long_title, uniqueness: { scope: :pi_id, message: 'There is an existing Research Master record with the same PI and Long Title' }
  validates :short_title, uniqueness: { scope: :pi_id, message: 'There is an existing Research Master record with the same PI and Short Title' }

  scope :with_associations_for_search, -> {
    joins("LEFT JOIN users AS creators ON creators.id = research_masters.creator_id")
    .joins("LEFT JOIN users AS pis ON pis.id = research_masters.pi_id")
    .joins("LEFT JOIN protocols as sparc_protocols ON sparc_protocols.id = research_masters.sparc_protocol_id")
    .joins("LEFT JOIN protocols as eirb_protocols ON eirb_protocols.id = research_masters.eirb_protocol_id")
    .joins("LEFT JOIN research_master_coeus_relations ON research_master_coeus_relations.research_master_id = research_masters.id")
    .joins("LEFT JOIN protocols as coeus_protocols ON coeus_protocols.id = research_master_coeus_relations.protocol_id")
    .joins("LEFT JOIN research_master_cayuse_relations ON research_master_cayuse_relations.research_master_id = research_masters.id")
    .joins("LEFT JOIN protocols as cayuse_protocols ON cayuse_protocols.id = research_master_cayuse_relations.protocol_id")
}

  ransacker :pi_sort_name do |parent|
    Arel.sql("COALESCE(NULLIF(pis.last_name, ''), pis.name)")
  end

  ransacker :pi_last_name do |parent|
    Arel.sql <<-SQL
      (
        SELECT COALESCE(NULLIF(users.last_name, ''), SUBSTRING_INDEX(users.name, ' ', -1))
        FROM users
        WHERE users.id = research_masters.pi_id
      )
    SQL
  end

  ransacker :creator_sort_name do |parent|
    Arel.sql("COALESCE(NULLIF(creators.last_name, ''), creators.name)")
  end

  ransacker :combined_search do |parent|
    Arel::Nodes::NamedFunction.new(
      'CONCAT_WS',
      [
        Arel::Nodes.build_quoted(' '),
        Arel::Nodes::SqlLiteral.new("CAST(research_masters.id AS CHAR)"),
        Arel::Nodes::SqlLiteral.new("CAST(research_masters.short_title AS CHAR)"),
        Arel::Nodes::SqlLiteral.new("CAST(creators.name AS CHAR)"),
        Arel::Nodes::SqlLiteral.new("CAST(creators.last_name AS CHAR)"),
        Arel::Nodes::SqlLiteral.new("CAST(creators.first_name AS CHAR)"),Arel::Nodes::SqlLiteral.new("CAST(pis.name AS CHAR)"),
        Arel::Nodes::SqlLiteral.new("CAST(pis.last_name AS CHAR)"),
        Arel::Nodes::SqlLiteral.new("CAST(pis.first_name AS CHAR)"),
        Arel::Nodes::SqlLiteral.new("CAST(research_masters.created_at AS CHAR)"),
        Arel::Nodes::SqlLiteral.new("CAST(sparc_protocols.sparc_id AS CHAR)"),
        Arel::Nodes::SqlLiteral.new("CAST(eirb_protocols.eirb_id AS CHAR)"),
        Arel::Nodes::SqlLiteral.new("CAST(research_masters.updated_at AS CHAR)"),
        Arel::Nodes::SqlLiteral.new("CAST(coeus_protocols.mit_award_number AS CHAR)"),
        Arel::Nodes::SqlLiteral.new("CAST(cayuse_protocols.cayuse_project_number AS CHAR)")
      ]
    )
  end

  def self.validated
    where(eirb_validated: true)
  end

  def has_attached_data?
    eirb_validated? or sparc_protocol_id? or coeus_protocols.any? or cayuse_protocols.any?
  end

  def eirb_closed_out_study?
    if eirb_protocol_id?
      eirb_protocol = Protocol.find(self.eirb_protocol_id)
      if eirb_protocol
        eirb_protocol.eirb_state == 'Terminated' or eirb_protocol.eirb_state == 'Completed' or eirb_protocol.eirb_state == 'Exempt Complete'
      end
    end
  end
end

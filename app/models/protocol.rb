class Protocol < ApplicationRecord
  audited
  self.inheritance_column = nil
  has_one :primary_pi
  has_many :research_master_coeus_relations
  has_many :research_masters, through: :research_master_coeus_relations
end

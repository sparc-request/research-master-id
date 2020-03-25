class Protocol < ApplicationRecord
  audited
  self.inheritance_column = nil

  belongs_to :primary_pi, class_name: 'User', optional: true

  has_many :research_master_coeus_relations
  has_many :research_masters, through: :research_master_coeus_relations

  has_many :research_master_cayuse_relations
  has_many :research_masters, through: :research_master_cayuse_relations
end

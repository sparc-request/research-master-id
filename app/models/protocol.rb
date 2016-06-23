class Protocol < ActiveRecord::Base
  self.inheritance_column = nil # ignore STI
  include SparcShard

  has_many :research
end

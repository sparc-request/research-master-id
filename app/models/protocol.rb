class Protocol < ActiveRecord::Base
  self.inheritance_column = nil
  has_one :primary_pi, dependent: :destroy
end

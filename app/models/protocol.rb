class Protocol < ApplicationRecord
  self.inheritance_column = nil
  has_one :primary_pi, dependent: :destroy
end

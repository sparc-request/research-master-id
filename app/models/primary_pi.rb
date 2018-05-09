class PrimaryPi < ApplicationRecord
  belongs_to :protocol, optional: true
  belongs_to :department, optional: true
end

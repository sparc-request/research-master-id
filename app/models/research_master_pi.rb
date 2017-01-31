class ResearchMasterPi < ActiveRecord::Base
  belongs_to :research_master

  validates :name, :email, presence: true

  validates_format_of :email, with: /\A\S+@.+\.\S+\z/, on: :create,
    allow_blank: true
end

class Identity < ActiveRecord::Base
  include SparcShard

  has_many :project_roles

  def self.primary_pi_list
    project_roles.where(role: 'primary-pi')
  end
end
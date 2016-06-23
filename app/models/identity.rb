class Identity < ActiveRecord::Base
  include SparcShard

  has_many :project_roles

  def self.primary_pi_list
    joins(:project_roles).where(project_roles: { role: 'primary-pi' })
  end
end

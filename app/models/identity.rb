class Identity < ActiveRecord::Base
  include SparcShard

  has_many :project_roles

  def self.primary_pi_list
    joins(:project_roles).where(project_roles: { role: 'primary-pi' }).distinct
  end

  def full_name
    "#{last_name.humanize}, #{first_name.humanize}"
  end
end

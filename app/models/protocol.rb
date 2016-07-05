class Protocol < ActiveRecord::Base
  self.inheritance_column = nil # ignore STI
  include SparcShard

  has_many :research_masters
  has_many :project_roles

  def primary_principal_investigator
    primary_pi_project_role.identity
  end

  def primary_pi_project_role
    project_roles.detect { |pr| pr.role == 'primary-pi' }
  end

  private

  def self.ransackable_scopes
    %i(primary_principal_investigator)
  end
end

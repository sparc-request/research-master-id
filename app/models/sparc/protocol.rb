class Sparc::Protocol < Sparc::Connection
  has_many :project_roles
  has_one :primary_pi
  has_one :human_subjects_info
  self.inheritance_column = nil

  def primary_principal_investigator
	  primary_pi_project_role.try(:idenity)
  end

  def primary_pi_project_role
	  project_roles.detect { |pr| pr.role == 'primary-pi' }
  end
end

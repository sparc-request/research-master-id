class Sparc::Protocol < Sparc::Connection

  self.table_name = "protocols"
  has_many :project_roles
  has_one :primary_pi
  has_one :human_subjects_info
  self.inheritance_column = nil

  has_one :primary_pi_role, -> { where(role: 'primary-pi', project_rights: 'approve') }, class_name: "ProjectRole"
  has_one :primary_pi, through: :primary_pi_role, source: :identity

  def primary_principal_investigator
    primary_pi_project_role.try(:idenity)
  end

  def primary_pi_project_role
    project_roles.detect { |pr| pr.role == 'primary-pi' }
  end
end

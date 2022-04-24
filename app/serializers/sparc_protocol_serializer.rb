class SparcProtocolSerializer < ActiveModel::Serializer
  attributes :id, :type, :first_name, :last_name, :title, :pro_number, :pi_department, :research_master_id, :short_title, :email, :ldap_uid

  def type
    'SPARC'
  end

  def email
    unless object.primary_principal_investigator.nil?
      object.primary_principal_investigator.admin_email
    else
      'N/A'
    end
  end

  def ldap_uid
    unless object.primary_principal_investigator.nil?
      object.primary_principal_investigator.ldap_uid
    else
      'N/A'
    end
  end

  def first_name
    unless object.primary_principal_investigator.nil?
      object.primary_principal_investigator.first_name
    else
      'N/A'
    end
  end

  def last_name
    unless object.primary_principal_investigator.nil?
      object.primary_principal_investigator.last_name
    else
      'N/A'
    end
  end
       
  def pro_number
    if object.human_subjects_info.present? && object.human_subjects_info.irb_records.first.present?
      object.human_subjects_info.irb_records.first.pro_number
    end
  end
  
  def pi_department
    unless object.primary_principal_investigator.nil?
      unless object.primary_principal_investigator.professional_organization_id.nil?
        ProfessionalOrganization.find(object.primary_principal_investigator.professional_organization_id).name
      else
        'N/A'
      end
    else
      'N/A'
    end
  end
end

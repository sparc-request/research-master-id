# Copyright © 2020 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

class Sparc::Protocol < Sparc::Connection

  self.table_name = "protocols"
  has_many :project_roles
  has_one :primary_pi
  has_one :human_subjects_info
  self.inheritance_column = nil

  has_one :primary_pi_role, -> { where(role: 'primary-pi', project_rights: 'approve') }, class_name: "ProjectRole"
  has_one :primary_pi, through: :primary_pi_role, source: :identity

  def type
    'SPARC'
  end

  def email
    unless self.primary_pi.nil?
      self.primary_pi.email
    else
      'N/A'
    end
  end

  def ldap_uid
    unless self.primary_pi.nil?
      self.primary_pi.ldap_uid
    else
      'N/A'
    end
  end

  def first_name
    unless self.primary_pi.nil?
      self.primary_pi.first_name
    else
      'N/A'
    end
  end

  def last_name
    unless self.primary_pi.nil?
      self.primary_pi.last_name
    else
      'N/A'
    end
  end

  def pro_number
    if self.human_subjects_info.present? && self.human_subjects_info.irb_records.first.present?
      self.human_subjects_info.irb_records.first.pro_number
    end
  end

  def pi_department
    unless self.primary_pi.nil?
      unless self.primary_pi.professional_organization_id.nil?
        Sparc::ProfessionalOrganization.find(self.primary_pi.professional_organization_id).name
      else
        'N/A'
      end
    else
      'N/A'
    end
  end

end

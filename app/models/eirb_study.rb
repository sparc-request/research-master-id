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

class EirbStudy < EirbConnection

  self.table_name = "view___Study"
  self.primary_key = "pro_number"

  has_many :keywords, :foreign_key => :pro_number

  ### different scopes for returning data ###

  def self.approved
    where(project_status: 'Approved')
  end

  def self.enrolling
    where(status_description: ['Approved for Accrual', 'Enrolling Subjects - No accrual/enrollment to date', 'Enrolling Subjects and/or Collecting Data'])
  end

  def self.not_enrolling
    where.not(status_description: ['Approved for Accrual', 'Enrolling Subjects - No accrual/enrollment to date', 'Enrolling Subjects and/or Collecting Data'])
  end

  def self.complete
    where(project_status: 'Completed')
  end

  def self.published
    where('is_published = ? AND contact_name IS NOT NULL', 1)
  end

  def self.is_musc
    where(institution_id: 'MUSC0')
  end

  def self.filter_invalid_pro_numbers
    where.not('pro_number like ? OR pro_number LIKE ?', "%MS%", "%Original%")
  end

  def self.filter_out_preserve_state
    where.not(project_status: 'Preserve')
  end

  def type
    'EIRB'
  end

  def pi_name
    "#{principal_investigator_first_name} #{principal_investigator_last_name}".lstrip.rstrip
  end

  def as_json(options={})
    self.attributes.merge({keywords: self.keywords.map(&:keyword).join(',')})
  end

  def self.recently_updated
    where('updated_at >= ?', 1.month.ago)
  end


end



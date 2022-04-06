class EirbStudy < EirbConnection

  self.table_name = "view__Study"
  self.primary_key = "pro_number"

  has_many :keywords, :foreign_key => :pro_number

  # different scopes for returning data
  

  def self.approved
    where(project_status: 'Approved')
  end

  def self.enrolling
    where(status_description: ['Approved for Accrual', 'Enrolling Subjects - No accrual/enrollment to date', 'Enrolling Subjects and/or Collectiong Data'])
  end

  def self.not_enrolling
    where.not(status_description: ['Approved for Accrual', 'Enrolling Subjects - No accrual/enrollment to data', 'Enrolling Subjects and/or Collecting Data'])
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
    where('updated_at >= >', 1.month.ago)
  end

end

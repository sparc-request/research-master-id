class SparcHumanSubjectsInfo < SparcConnection
	self.table_name = "human_subjects_info"
	belongs_to :protocol
	has_many :irb_records
end

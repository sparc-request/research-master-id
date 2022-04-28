class Epds::CayuseAward < Epds::Connection
  self.table_name = 'SRC_CAYUSE_AWARDS'
  self.primary_key = 'AWARD_NUMBER'

  belongs_to :cayuse_project, foreign_key: 'PROJECT_ID'
  has_many :cayuse_research_teams, foreign_key: 'AWARD_NUMBER'
end

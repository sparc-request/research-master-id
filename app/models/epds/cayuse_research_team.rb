class Epds::CayuseResearchTeam < Epds::Connection
  self.table_name = 'SRC_CAYUSE_RESEARCH_TEAM'
  self.primary_key = 'PID'
  belongs_to :cayuse_award, foreign_key: 'AWARD_NUMBER'
end

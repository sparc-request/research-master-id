class Epds::CayuseProject < Epds::Connection
  self.table_name = "SRC_CAYUSE_PROJECTS"
  self.primary_key = "PROJECT_ID"
  

  has_many :cayuse_awards, foreign_key: 'PROJECT_ID'
  has_many :cayuse_research_teams, through: :cayuse_awards

  def self.has_rmid
    where.not(RMID: [nil, 0])
  end

  def pi_list
    # Grabs all research team records, which have tons of duplicates because of multiple 'award years'.
    # So we have to unique the names after combining first and last.
    cayuse_research_teams.where(ROLE: 'Lead Principal Investigator').map{ |rt| rt.FNAME + " " + rt.LNAME }.uniq
  end

end

class Epds::CoeusAwardDetail < Epds::Connection
  self.table_name = "SRC_ORSP_AWARD_DETAILS"

  def self.valid_protocols
    where.not(AWARD_STATUS: "Inactive (Void)")
  end

  def self.with_highest_sequence_number
    query = <<-SQL
      select subset.mit_award_number, subset.max as sequence_number from(
        select mit_award_number, max(sequence_number) as max from coeus_data.SRC_ORSP_AWARD_DETAILS 
        group by mit_award_number
      ) subset
    SQL
    results = ActiveRecord::Base.connection.execute(query)
    results.as_json

    ads = []
    results.as_json.each do |result|
      ad = CoeusAwardDetail.find_by(MIT_AWARD_NUMBER: result[0])
      ads << ad
    end
    ads
  end
end

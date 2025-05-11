class AddOriginalPiIdToResearchMasters < ActiveRecord::Migration[5.2]
  def change
    add_column :research_masters, :original_pi_id, :integer, after: :previous_pi_id
  end
end

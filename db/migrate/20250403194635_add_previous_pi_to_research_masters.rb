class AddPreviousPiToResearchMasters < ActiveRecord::Migration[5.2]
  def change
    add_reference :research_masters, :previous_pi, foreign_key: { to_table: :users }, after: :pi_id, type: :integer
    add_column :research_masters, :pi_change_date, :datetime, after: :previous_pi_id
  end
end

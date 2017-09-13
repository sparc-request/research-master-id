class IncreaseLengthOfResearchMasterLongTitle < ActiveRecord::Migration[4.2]
  def up
    change_column :research_masters, :long_title, :text
  end

  def down
    change_column :research_masters, :long_title, :string
  end
end

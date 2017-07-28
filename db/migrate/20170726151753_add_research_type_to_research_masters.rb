class AddResearchTypeToResearchMasters < ActiveRecord::Migration[5.1]
  def change
    add_column :research_masters, :research_type, :string
  end
end

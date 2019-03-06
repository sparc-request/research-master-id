class RemoveResearchMastersDepartmentColumn < ActiveRecord::Migration[5.1]
  def change
    remove_column :research_masters, :department
  end
end

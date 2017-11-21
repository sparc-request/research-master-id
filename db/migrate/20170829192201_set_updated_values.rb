class SetUpdatedValues < ActiveRecord::Migration[5.1]
  def change
    ResearchMaster.update_all("creator_id=user_id")
  end
end

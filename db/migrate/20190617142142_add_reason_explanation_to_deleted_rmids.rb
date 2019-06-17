class AddReasonExplanationToDeletedRmids < ActiveRecord::Migration[5.2]
  def change
    add_column :deleted_rmids, :explanation, :text
    change_column :deleted_rmids, :reason, :string
  end
end

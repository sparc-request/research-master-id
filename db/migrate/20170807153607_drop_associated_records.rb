class DropAssociatedRecords < ActiveRecord::Migration[5.1]
  def change
    drop_table :associated_records
  end
end

class DropPrimaryPisTable < ActiveRecord::Migration[5.2]
  def change
    drop_table :primary_pis
  end
end

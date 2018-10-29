class ConvertEirbDatesToDate < ActiveRecord::Migration[5.1]
  def change
    change_column :protocols, :date_initially_approved, :date
    change_column :protocols, :date_approved, :date
    change_column :protocols, :date_expiration, :date
  end
end

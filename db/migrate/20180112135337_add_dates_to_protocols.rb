class AddDatesToProtocols < ActiveRecord::Migration[5.1]
  def change
    add_column :protocols, :date_initially_approved, :datetime, after: :eirb_state
    add_column :protocols, :date_approved, :datetime, after: :date_initially_approved
    add_column :protocols, :date_expiration, :datetime, after: :date_approved
  end
end

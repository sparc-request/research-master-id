class AddSparcProNumberToProtocols < ActiveRecord::Migration
  def change
    add_column :protocols, :sparc_pro_number, :string, after: :eirb_state
  end
end

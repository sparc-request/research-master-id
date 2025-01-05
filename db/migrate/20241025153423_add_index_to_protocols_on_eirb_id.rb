class AddIndexToProtocolsOnEirbId < ActiveRecord::Migration[5.2]
  def change
    add_index :protocols, :eirb_id
  end
end

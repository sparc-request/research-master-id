class AddStateToProtocols < ActiveRecord::Migration[4.2]
  def change
    add_column :protocols, :eirb_state, :string, after: :eirb_institution_id
  end
end

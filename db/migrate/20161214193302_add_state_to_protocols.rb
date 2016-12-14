class AddStateToProtocols < ActiveRecord::Migration
  def change
    add_column :protocols, :eirb_state, :string, after: :eirb_institution_id
  end
end

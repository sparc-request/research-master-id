class AddInstitutionIdToProtocols < ActiveRecord::Migration[4.2]
  def change
    add_column :protocols, :eirb_institution_id, :string, after: :eirb_id
  end
end

class AddStatusDescriptionToProtocols < ActiveRecord::Migration[5.2]
  def change
    add_column :protocols, :status_description, :string
  end
end

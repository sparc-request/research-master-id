class AddCayuseInfoToProtocols < ActiveRecord::Migration[5.2]
  def change
    add_column :protocols, :cayuse_project_number, :string
    add_column :protocols, :cayuse_pi_name, :string
  end
end

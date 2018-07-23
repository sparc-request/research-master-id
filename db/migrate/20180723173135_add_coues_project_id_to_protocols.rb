class AddCouesProjectIdToProtocols < ActiveRecord::Migration[5.1]
  def change
    add_column :protocols, :coeus_project_id, :string
  end
end

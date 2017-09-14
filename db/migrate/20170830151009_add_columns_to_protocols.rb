class AddColumnsToProtocols < ActiveRecord::Migration[5.1]
  def change
    add_column :protocols, :mit_award_number, :string, after: :sparc_pro_number
    add_column :protocols, :sequence_number, :string, after: :mit_award_number
    add_column :protocols, :title, :string, after: :sequence_number
    add_column :protocols, :entity_award_number, :string, after: :title
    add_column :protocols, :coeus_protocol_number, :string, after: :entity_award_number
  end
end

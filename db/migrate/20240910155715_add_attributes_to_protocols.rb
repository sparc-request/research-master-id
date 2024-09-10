class AddAttributesToProtocols < ActiveRecord::Migration[5.2]
  def change
    add_column :protocols, :irb_committee_name, :string
    add_column :protocols, :external_irb_of_record, :string
    add_column :protocols, :other_external_irb_text, :string
    add_column :protocols, :clinical_study_phase, :string
  end
end

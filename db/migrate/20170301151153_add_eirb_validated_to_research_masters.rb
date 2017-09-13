class AddEirbValidatedToResearchMasters < ActiveRecord::Migration[4.2]
  def change
    add_column :research_masters, :eirb_validated, :boolean, after: :funding_source, default: false
  end
end

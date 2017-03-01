class AddEirbValidatedToResearchMasters < ActiveRecord::Migration
  def change
    add_column :research_masters, :eirb_validated, :boolean, after: :funding_source, default: false
  end
end

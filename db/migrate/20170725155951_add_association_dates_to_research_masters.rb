class AddAssociationDatesToResearchMasters < ActiveRecord::Migration[5.1]
  def change
    add_column :research_masters, :eirb_association_date, :datetime, after: :eirb_protocol_id
    add_column :research_masters, :sparc_association_date, :datetime, after: :eirb_association_date
  end
end

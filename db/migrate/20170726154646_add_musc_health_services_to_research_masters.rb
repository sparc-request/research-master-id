class AddMuscHealthServicesToResearchMasters < ActiveRecord::Migration[5.1]
  def change
    add_column :research_masters, :musc_health_services, :boolean
  end
end

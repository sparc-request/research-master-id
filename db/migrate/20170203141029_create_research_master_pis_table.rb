class CreateResearchMasterPisTable < ActiveRecord::Migration[4.2]
  def change
    create_table :research_master_pis do |t|
      t.string :name
      t.string :email
      t.string :department
      t.references :research_master, index: true, foreign_key: true
    end
  end
end

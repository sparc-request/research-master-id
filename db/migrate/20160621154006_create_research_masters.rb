class CreateResearchMasters < ActiveRecord::Migration[4.2]
  def change
    create_table :research_masters do |t|
      t.string :pi_name
      t.string :department
      t.string :long_title
      t.string :short_title
      t.string :funding_source
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end

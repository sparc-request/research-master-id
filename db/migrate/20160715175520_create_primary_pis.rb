class CreatePrimaryPis < ActiveRecord::Migration[4.2]
  def change
    create_table :primary_pis do |t|
      t.string :name
      t.references :protocol, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end

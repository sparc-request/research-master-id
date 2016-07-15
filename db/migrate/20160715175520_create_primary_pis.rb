class CreatePrimaryPis < ActiveRecord::Migration
  def change
    create_table :primary_pis do |t|
      t.string :name
      t.string :department
      t.references :protocol, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end

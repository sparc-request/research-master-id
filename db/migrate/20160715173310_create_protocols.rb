class CreateProtocols < ActiveRecord::Migration
  def change
    create_table :protocols do |t|
      t.string :type
      t.string :pi_name
      t.string :department
      t.text :long_title
      t.string :short_title
      t.string :funding_source
      t.integer :sparc_id
      t.integer :coeus_id
      t.integer :eirb_id

      t.timestamps null: false
    end
  end
end

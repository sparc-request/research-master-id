class CreateProtocols < ActiveRecord::Migration
  def change
    create_table :protocols do |t|
      t.string :type
      t.text :long_title
      t.integer :sparc_id
      t.integer :coeus_id
      t.string :eirb_id

      t.timestamps null: false
    end
  end
end

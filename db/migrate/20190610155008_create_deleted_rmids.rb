class CreateDeletedRmids < ActiveRecord::Migration[5.2]
  def change
    create_table :deleted_rmids do |t|
      t.integer :original_id
      t.string :long_title
      t.string :short_title
      t.integer :creator_id
      t.integer :pi_id
      t.integer :sparc_protocol_id
      t.integer :eirb_protocol_id
      t.string :research_type
      t.integer :user_id
      t.text :reason

      t.timestamps null: false
    end
  end
end

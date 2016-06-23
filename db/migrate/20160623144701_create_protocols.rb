class CreateProtocols < ActiveRecord::Migration
  def change
    create_table :protocols do |t|
      t.string :short_title
      t.string :long_title
      t.string :funding_source
      t.string :funding_status

      t.timestamps null: false
    end
  end
end

class AddPhoneToIdentities < ActiveRecord::Migration
  def change
    add_column :identities, :phone, :string
  end
end

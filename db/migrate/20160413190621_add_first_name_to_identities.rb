class AddFirstNameToIdentities < ActiveRecord::Migration
  def change
    add_column :identities, :first_name, :string
  end
end

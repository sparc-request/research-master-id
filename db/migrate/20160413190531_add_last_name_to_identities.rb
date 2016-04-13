class AddLastNameToIdentities < ActiveRecord::Migration
  def change
    add_column :identities, :last_name, :string
  end
end

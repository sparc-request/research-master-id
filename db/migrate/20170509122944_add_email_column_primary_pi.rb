class AddEmailColumnPrimaryPi < ActiveRecord::Migration[5.0]
  def change
    add_column :primary_pis, :email, :string, after: :last_name
  end
end

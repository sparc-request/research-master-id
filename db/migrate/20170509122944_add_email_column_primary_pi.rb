class AddEmailColumnPrimaryPi < ActiveRecord::Migration
  def change
    add_column :primary_pis, :email, :string, after: :last_name
  end
end

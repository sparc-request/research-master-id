class AddNetIdToPrimaryPis < ActiveRecord::Migration[5.1]
  def change
    add_column :primary_pis, :net_id, :string, after: :email
  end
end

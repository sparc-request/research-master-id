class ReconfigurePiName < ActiveRecord::Migration
  def change
    add_column :primary_pis, :last_name, :string, after: :name
    rename_column :primary_pis, :name, :first_name
    PrimaryPi.all.each do |pi|
      split = pi.first_name.split(' ')
      pi.first_name = split[0]
      pi.last_name = split[1]
      pi.save
    end
  end
end

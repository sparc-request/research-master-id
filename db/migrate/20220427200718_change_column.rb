class ChangeColumn < ActiveRecord::Migration[5.2]
  def up
    change_column :protocols, :cayuse_pi_name, :longtext
  end

  def down
    change_column :protocols, :cayuse_pi_name, :text
  end

end

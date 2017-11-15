class RemoveForeignKeyUsers < ActiveRecord::Migration[5.1]
  def change
    remove_reference(:research_masters, :user, index: true, foreign_key: true)
  end
end

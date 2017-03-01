class AddShortTitleToProtocols < ActiveRecord::Migration
  def change
    add_column :protocols, :short_title, :text, after: :type
  end
end

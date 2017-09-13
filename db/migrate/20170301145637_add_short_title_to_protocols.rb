class AddShortTitleToProtocols < ActiveRecord::Migration[4.2]
  def change
    add_column :protocols, :short_title, :text, after: :type
  end
end

class AddingAttributesToUsersTable < ActiveRecord::Migration[5.1]
  def up
    add_column :users, :pvid, :integer, after: :name
    add_column :users, :middle_initial, :string, after: :name
    add_column :users, :last_name, :string, after: :name
    add_column :users, :first_name, :string, after: :name

    User.reset_column_information

    bad_results = []
    l = LdapSearch.new

    User.all.each do |user|
      results = l.info_query(user.net_id, false, true)

      if results.size == 0 || results.size > 1
        bad_results << user.id
      else
        user_data = results.first
        user.update_attributes(first_name: user_data[:first_name], last_name: user_data[:last_name], middle_initial: user_data[:middle_initial], pvid: user_data[:pvid])
      end
    end

    puts "#"*50
    puts "#"*50
    puts "#"*50
    puts "#"*50
    puts bad_results.inspect
    puts "#"*50
    puts "#"*50
    puts "#"*50
    puts "#"*50



  end

  def down
    remove_column :users, :pvid
    remove_column :users, :middle_initial
    remove_column :users, :last_name
    remove_column :users, :first_name
  end
end

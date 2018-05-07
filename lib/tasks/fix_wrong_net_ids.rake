task fix_wrong_net_ids: :environment do
  CSV.foreach(Rails.root.join('public', 'wrong_net_ids.csv'), headers: true) do |row|
    begin
      user = User.find_by(email: row['email'])
      user.update_attribute(:net_id, row['net_id'])
    rescue
      puts "Could not find User with email - #{row['email']}"
    end
  end
end


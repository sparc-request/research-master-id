task populate_historic_departments: :environment do

  input_file = Rails.root.join("tmp", users_departments.csv)

  continue = prompt('Preparing to modify the users. Are you sure you want to continue? (y/n): ')

  if continue == 'y' || continue == 'Y'
    CSV.foreach(input_file, headers: true, :encoding => 'windows-1251:utf-8') do |row|
      user = User.find(row['USER ID'].to_i)
      unless user.current_prism_user?
        user.update_attributes(department: row['DEPARTMENT'])
      end
    end
  end 
end
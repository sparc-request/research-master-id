task populate_historic_departments: :environment do
  CSV.foreach(Rails.root.join("tmp", "users_departments.csv"), headers: true, :encoding => 'windows-1251:utf-8') do |row|
    user = User.where(id: row['USER ID'].to_i).first

    if user
      unless user.current_prism_user?
        user.update_attributes(department: row['DEPARTMENT'])
      end
    end
  end
end

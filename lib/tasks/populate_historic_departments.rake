task populate_historic_departments: :environment do

  def prompt(*args)
    print(*args)
    STDIN.gets.strip
  end

  def get_file(error=false)
    puts "No import file specified or the file specified does not exist in db/imports" if error
    file = prompt "Please specify the file name to import from tmp (must be a CSV): "

    while file.blank? or not File.exists?(Rails.root.join("tmp", file))
      file = get_file(true)
    end

    file
  end

  input_file = Rails.root.join("tmp", get_file)

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
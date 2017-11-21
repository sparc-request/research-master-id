task quick_fix_titles: :environment do

  masters = ResearchMaster.all

  puts "Forcing sanitization for all records"
  masters.each do |master|

    long_title = master.long_title + " "
    short_title = master.short_title + " "

    master.long_title = long_title
    master.short_title = short_title

    if master.save(validate: false)
      puts "Updated #{master.id}"
    else
      puts "Error fixing: #{master.errors.inspect}"
    end
  end
  puts "Sanitization complete"
end

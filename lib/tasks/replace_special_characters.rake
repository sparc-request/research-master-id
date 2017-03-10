task replace_special_characters: :environment do

  masters = ResearchMaster.all

  puts "Checking all #{masters.count} research master records"
  puts 'for special characters...'
  masters.each do |master|

    new_title = master.long_title.gsub(/[^a-zA-Z0-9\-.\s]/, ' ')

    if new_title != master.long_title
      puts "Research master with an id of #{master.id} has a special character"
      puts 'in the long title'
      master.update_attribute(:long_title, new_title)
    end
    
    new_title = master.short_title.gsub(/[^a-zA-Z0-9\-.\s]/, ' ')

    if new_title != master.short_title
      puts "Research master with an id of #{master.id} has a special character"
      puts 'in the short title'
      master.update_attribute(:short_title, new_title)
    end
    
  end
end
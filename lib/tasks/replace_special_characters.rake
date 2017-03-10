task replace_special_characters: :environment do

  masters = ResearchMaster.all

  puts "Checking all #{master.count} research master records"
  puts 'for special characters...'
  masters.each do |master|
    if master.long_title =~ /^[a-zA-Z\d\s.]*$/
      puts "Research master with an id of #{master.id} has a special character"
      puts 'in the long title'
      new_title = master.long_title.gsub!(/[^a-zA-Z0-9\-.\s]/, '')
      master.update_attributes(long_title: new_title)
    elsif master.long_title =~ /^[a-zA-Z\d\s.]*$/
      puts "Research master with an id of #{master.id} has a special character"
      puts 'in the short title'
      new_title = master.short_title.gsub!(/[^a-zA-Z0-9\-.\s]/, '')
      master.update_attributes(short_title: new_title)
    end
  end
end
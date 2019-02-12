status = %x[RAILS_ENV=#{Rails.env} bundle exec bin/delayed_job status]
puts "#"*50
puts status
puts "#"*50

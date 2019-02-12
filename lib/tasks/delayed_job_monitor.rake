require 'open3'
task delayed_job_monitor: :environment do
  stdout, stderr, status = Open3.capture3("RAILS_ENV=#{Rails.env} bundle exec bin/delayed_job status")
  prev_status = stderr

  if stderr =~ /delayed_job: no instances running/
    puts "Delayed Job is NOT running"

    stdout, stderr, status = Open3.capture3("RAILS_ENV=#{Rails.env} bundle exec bin/delayed_job start")
    curr_status = stdout

    Notifier.delayed_jobs_down("catesa@musc.edu", prev_status, curr_status).deliver!
  else
    puts "Delayed Job is running"
  end
end

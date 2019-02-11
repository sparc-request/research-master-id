require 'net/ssh'
require 'net/scp'
require 'dotenv/tasks'

task update_to_production: :environment do

  remote_host = ENV.fetch('REMOTE_HOST')
  remote_username = ENV.fetch('REMOTE_USERNAME')
  # fetch database connection information
  puts "Fetching database.yml from production"
  Net::SCP.download!(remote_host,
                     remote_username,
                     ENV.fetch('REMOTE_HOST_APPLICATION_FOLDER') + "/config/database.yml",
                     Rails.root.join("tmp/production_database.yml")
  )

  remote_db_config = YAML.load_file(Rails.root.join("tmp/production_database.yml"))['production']
  local_db_config = YAML.load_file(Rails.root.join("config/database.yml"))[Rails.env]

  Net::SSH.start(remote_host, remote_username) do |ssh|
    puts "Performing mysqldump on production"
    output = ssh.exec!("mysqldump -u #{remote_db_config['username']} -p#{remote_db_config['password']} -h #{remote_db_config['host']} #{remote_db_config['database']} --no-data > production_rmid.sql")
    output = ssh.exec!("mysqldump -u #{remote_db_config['username']} -p#{remote_db_config['password']} -h #{remote_db_config['host']} #{remote_db_config['database']} --ignore-table=#{remote_db_config['database']}.ar_internal_metadata --ignore-table=#{remote_db_config['database']}.audits >> production_rmid.sql")
    puts output

    puts "Compressing data"
    output = ssh.exec!("tar -czvf production_rmid.tar.gz production_rmid.sql")
    puts output
  end

  puts "Fetching data"
  local_io = File.new(Rails.root.join("tmp/production_rmid.tar.gz"), mode: 'w', encoding: 'ASCII-8BIT')
  Net::SCP.download!(remote_host,
                     remote_username,
                     "production_rmid.tar.gz",
                     local_io
  )
  local_io.close

  puts "Extracting data"
  `tar xzvf #{Rails.root.join("tmp/production_rmid.tar.gz")}`
  `mv #{Rails.root.join("production_rmid.sql")} #{Rails.root.join("tmp/production_rmid.sql")}`

  puts "Dropping local database"
  Rake::Task["db:drop"].invoke

  puts "Creating local database"
  Rake::Task["db:create"].invoke

  puts "Loading data"
  `mysql -u #{local_db_config['username']} -p#{local_db_config['password']} -h #{local_db_config['host']} #{local_db_config['database']} < #{Rails.root.join("tmp/production_rmid.sql")}`

  puts "Setting schema environment"
  `bin/rails db:environment:set RAILS_ENV=#{Rails.env}`

  puts "#### Last thing to do is use Capistrano to restart the server, we will not automate this ####"
end

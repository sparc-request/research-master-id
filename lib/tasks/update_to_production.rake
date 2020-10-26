# Copyright © 2011-2020 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

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
  if local_db_config['password']
    `mysql -u #{local_db_config['username']} -p#{local_db_config['password']} -h #{local_db_config['host']} #{local_db_config['database']} < #{Rails.root.join("tmp/production_rmid.sql")}`
  else
    `mysql -u #{local_db_config['username']} -h #{local_db_config['host']} #{local_db_config['database']} < #{Rails.root.join("tmp/production_rmid.sql")}`
  end

  puts "Setting schema environment"
  `bin/rails db:environment:set RAILS_ENV=#{Rails.env}`

  puts "Migrate local database"
  Rake::Task["db:migrate"].invoke

  puts "Restart passenger"
  `touch tmp/restart.txt`
end

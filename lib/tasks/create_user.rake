# Copyright © 2016 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

task :create_user => :environment do

  def prompt(*args)
      print(*args)
      STDIN.gets.strip
  end

  puts "This task will create a user with all rights for a given organization, for testing and development purposes."
  password = prompt "Enter a password for your new user that is 6 charaters or longer: "
  while password.size < 6
    password = prompt "Enter a password for your new user that is 6 charaters or longer: "
  end

  puts "The ldap uid is defaulted to 'felicia@musc.edu'"
  puts ""

  continue = prompt "Is this correct? (Yes/No): "

  if continue == "Yes"
    puts "Creating Felicia..."
    identity = Identity.create(:id => 'felicia@musc.edu',
                             :email => 'felicia@musc.edu',
                             :last_name => 'Castillo',
                             :first_name => 'Felicia',
                             :phone => '555-555-5555',
                             :password => "#{password}",
                             :password_confirmation => "#{password}")
    identity.save

    puts "Bye, Felicia..."
  end
end

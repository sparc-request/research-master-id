# Copyright © 2020 MUSC Foundation for Research Development~
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

task update_user_department: :environment do

  coeus_api   = ENV.fetch("COEUS_API")
  interfolio_users = HTTParty.get("#{coeus_api}/interfolio", timeout: 500, headers: {'Content-Type' => 'application/json'})
  $users      = User.all

  interfolio_users.each do |user|
    if user_to_update = $users.detect{ |u| u.net_id == user['netid'] }
      user_to_update.update_attribute(:department, user['department'])
    end
  end

  ldap_search = LdapSearch.new
  users = User.all

  missing_ldap_users = []

  users.each do |user|
    if user.net_id.present?
      ldap_user = ldap_search.info_query(user.email, false, false, 'email')
      unless ldap_user.present?
        missing_ldap_users << user
        puts "User '#{user.name}' was not found in ldap."
        next
      end

      department = ldap_user.first[:department]
      if !department.blank? && (user.department != department)
        puts "Updating #{user.department} to #{department}"
        user.department = department
        user.save(validate: false)
      else
        puts "User department matches ldap or ldap department is blank"
      end
    else
      missing_ldap_users << user
      puts "User '#{user.name}' is missing a net_id"
      next
    end
  end
  PiUpdateMailer.ldap_missing_email(missing_ldap_users, ['taylorby@musc.edu', 'forney@musc.edu', 'catesa@musc.edu', 'harikrip@musc.edu', 'etai@musc.edu']).deliver_now
end

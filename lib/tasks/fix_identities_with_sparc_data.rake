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

task fix_identities_with_sparc_data: :environment do
  sparc_api = ENV.fetch('SPARC_API')

  identities = HTTParty.get(
    "#{sparc_api}/identities",
    timeout: 500,
    headers: { 'Content-Type' => 'application/json' }
  )

  identities.each do |identity|
    if User.exists?(email: identity['email'])
      user = User.find_by(email: identity['email'])
      if user.net_id == '[]' || user.net_id == nil
        user.update_attribute(:net_id, identity['ldap_uid'].remove('@musc.edu'))
      end
      if user.name == '[]' || user.name == nil
        user.update_attribute(:name, "#{identity['first_name']} #{identity['last_name']}")
      end
    end
  end

  user_one = User.find(698)

  ResearchMaster.find_by(creator_id: user_one.id).update_attribute(:creator_id, 709)

  user_one.destroy

  user_two = User.find(195)

  ResearchMaster.find_by(creator_id: user_two.id).update_attribute(:creator_id, 1464)

  user_two.destroy

  user_three = User.find(178)
  user_three.update_attribute(:email, 'nelsonjd@musc.edu')
  user_three.update_attribute(:net_id, 'jod9')
  user_three.update_attribute(:name, 'Joni Nelson')
end


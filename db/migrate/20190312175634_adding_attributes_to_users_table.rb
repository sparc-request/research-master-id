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

class AddingAttributesToUsersTable < ActiveRecord::Migration[5.1]
  def up
    add_column :users, :pvid, :integer, after: :name
    add_column :users, :middle_initial, :string, after: :name
    add_column :users, :last_name, :string, after: :name
    add_column :users, :first_name, :string, after: :name

    User.reset_column_information

    bad_results = []
    l = LdapSearch.new

    User.all.each do |user|
      results = l.info_query(user.net_id, false, true)

      if results.size == 0 || results.size > 1
        bad_results << user.id
      else
        user_data = results.first
        user.update_attributes(
          name: user_data[:name],
          first_name: user_data[:first_name],
          last_name: user_data[:last_name],
          middle_initial: user_data[:middle_initial],
          pvid: user_data[:pvid])
      end
    end

    puts "#"*50
    puts "#"*50
    puts "#"*50
    puts "#"*50
    puts bad_results.inspect
    puts "#"*50
    puts "#"*50
    puts "#"*50
    puts "#"*50
  end

  def down
    remove_column :users, :pvid
    remove_column :users, :middle_initial
    remove_column :users, :last_name
    remove_column :users, :first_name
  end
end

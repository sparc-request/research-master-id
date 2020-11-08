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

task replace_special_characters: :environment do

  masters = ResearchMaster.all

  puts "Checking all #{masters.count} research master records"
  puts 'for special characters...'
  masters.each do |master|

    new_title = master.long_title.gsub(/[^a-zA-Z0-9\-.\s%\/$*<>!@#^\[\]{};:"'?&()-_=+]/, ' ')

    if new_title != master.long_title
      puts "Research master with an id of #{master.id} has a special character"
      puts 'in the long title'
      master.update_attribute(:long_title, new_title)
    end

    new_title = master.short_title.gsub(/[^a-zA-Z0-9\-.\s%\/$*<>!@#^\[\]{};:"'?&()-_=+]/, ' ')

    if new_title != master.short_title
      puts "Research master with an id of #{master.id} has a special character"
      puts 'in the short title'
      master.update_attribute(:short_title, new_title)
    end
  end
end

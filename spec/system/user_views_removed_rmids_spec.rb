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

require 'rails_helper'

RSpec.describe 'Viewing removed RMIDs', type: :system, js: true do
  let(:user) { User.first }
  let(:research_master) { create(:research_master) }

  before do
    # 1. Create and sign in the user (This user becomes User.first)
    create_and_sign_in_user
    
    # 2. Grant them admin rights
    user.update!(admin: true)
    
    # 3. NOW create the research master so the factory doesn't steal User.first!
    research_master 
  end

  it 'lists the removed RMID on the deleted RMIDs page' do
    visit root_path

    # Trigger the deletion modal
    find('.research-master-delete').click

    # Fill out and submit the modal
    select 'Duplicate Entry', from: 'reason'
    find('input.reason_submit').click

    # Confirm the sweetalert
    find('button.confirm').click

    # CRITICAL: Force Capybara to wait for the AJAX delete to finish
    # before navigating away from the current page!
    expect(page).not_to have_content(research_master.short_title)

    # Now it is safe to navigate to the deleted records page
    visit deleted_rmids_path

    # Verify it successfully landed in the deleted list
    expect(page).to have_content(research_master.short_title)
  end
end

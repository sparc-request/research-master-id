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

RSpec.describe 'Removing an RMID', type: :system, js: true do
  let(:user) { User.first }

  # Define the helper inside the block so it doesn't pollute the global test scope
  def remove_and_test_for(rm)
    find('.research-master-delete').click

    select 'Duplicate Entry', from: 'reason'
    find('input.reason_submit').click

    expect(page).to have_content('Research Master record has been deleted')
    find('button.confirm').click
    
    # Capybara will natively wait for the modal to close and the DOM to update
    expect(page).not_to have_content(rm.short_title)
  end

  describe 'with attached data' do
    let(:research_master) { create(:research_master, eirb_validated: true) }

    before do
      create_and_sign_in_user
      research_master # Trigger the let block to instantiate the record in the DB
    end

    context 'as an admin user' do
      before do
        user.update!(admin: true)
        visit root_path
      end

      it 'removes the record' do
        remove_and_test_for(research_master)
      end
    end

    context 'as the creator' do
      before do
        research_master.update!(creator_id: user.id)
        visit root_path
      end

      it 'disables the remove button' do
        expect(page).to have_css('.research-master-delete.disabled')
      end
    end

    context 'as the pi' do
      before do
        research_master.update!(pi_id: user.id)
        visit root_path
      end

      it 'disables the remove button' do
        expect(page).to have_css('.research-master-delete.disabled')
      end
    end
  end

  describe 'without attached data' do
    let(:research_master) { create(:research_master, eirb_validated: false) }

    before do
      create_and_sign_in_user
      research_master # Trigger the let block to instantiate the record in the DB
    end

    context 'as the creator' do
      before do
        research_master.update!(creator_id: user.id)
        visit root_path
      end

      it 'removes the record' do
        remove_and_test_for(research_master)
      end
    end

    context 'as the pi' do
      before do
        research_master.update!(pi_id: user.id)
        visit root_path
      end

      it 'removes the record' do
        remove_and_test_for(research_master)
      end
    end

    context 'as a regular user' do
      before do
        visit root_path
      end

      it 'disables the remove button' do
        expect(page).to have_css('.research-master-delete.disabled')
      end
    end
  end
end

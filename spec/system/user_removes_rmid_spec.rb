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

RSpec.describe 'Removing an RMID', js: true do

  describe 'with attached data' do
    before :each do
      create_and_sign_in_user
      @user = User.first
      @research_master = create(:research_master, eirb_validated: true)
    end

    describe 'as an admin user' do
      it "should be removed" do
        User.first.update_attributes(admin: true)
        visit root_path
        wait_for_ajax

        remove_and_test_for_rmid
      end
    end

    describe 'as the creator' do

      it "should not be removed" do
        @research_master.update_attributes(creator_id: @user.id)
        visit root_path
        wait_for_ajax

        expect(page).to have_css('.research-master-delete.disabled')
      end
    end

    describe 'as the pi' do
      it "should not be removed" do
        @research_master.update_attributes(pi_id: @user.id)
        visit root_path
        wait_for_ajax

        expect(page).to have_css('.research-master-delete.disabled')
      end
    end
  end

  describe 'without attached data' do
    before :each do
      create_and_sign_in_user
      @user = User.first
      @research_master = create(:research_master)
    end

    describe 'as the creator' do
      it "should be removed" do
        @research_master.update_attribute(:creator_id, @user.id)
        visit root_path
        wait_for_ajax

        remove_and_test_for_rmid
      end
    end

    describe 'as the pi' do
      it "should be removed" do
        @research_master.update_attributes(pi_id: @user.id)
        visit root_path
        wait_for_ajax

        remove_and_test_for_rmid
      end
    end

    describe 'as a regular user' do
      it "should not be removed" do
        visit root_path
        wait_for_ajax

        expect(page).to have_css('.research-master-delete.disabled')
      end
    end
  end
end

def remove_and_test_for_rmid
  find('.research-master-delete').click
  wait_for_ajax

  select "Duplicate Entry", :from => "reason"
  find('input.reason_submit').click
  wait_for_ajax

  expect(page).to have_content("Research Master record has been deleted")
  find('button.confirm').click
  wait_for_ajax
  expect(page).not_to have_content(@research_master.short_title)
end

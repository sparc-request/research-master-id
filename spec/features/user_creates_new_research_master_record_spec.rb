require 'rails_helper'

feature 'User should be able to create a new research master record', js: true do

  describe 'bringing up the modal' do

    it 'should bring up the modal once the Create New button is clicked' do
      create_and_sign_in_user
    
      find('#create_new').click
      wait_for_ajax
      expect(page).to have_content('New Research Master Record')
    end
  end

  describe 'creating new reserch master record' do

    it 'should create a new record upon form submission' do
      create_and_sign_in_user
    
      find('#create_new').click
      wait_for_ajax

      
    end
  end
end
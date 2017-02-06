require 'rails_helper'

describe NullUser do
  describe '#name' do
    it 'should return not available' do
      null_user = NullUser.new

      result = null_user.name

      expect(result).to eq 'Not Available'
    end
  end

  describe '#email' do
    it 'should return not available' do
      null_user = NullUser.new

      result = null_user.email

      expect(result).to eq 'Not Available'
    end
  end
end


require 'rails_helper'

describe LdapSearch do

  describe '#email_query' do
    it 'should return my email' do
      ldap_search = LdapSearch.new

      result = ldap_search.email_query('wih205')

      expect(result).to eq 'holtw@musc.edu'
    end

    it 'should return Jays email' do
      ldap_search = LdapSearch.new

      result = ldap_search.email_query('anc63')

      expect(result).to eq 'catesa@musc.edu'
    end

    it 'should fail if invalid uid' do
      ldap_search = LdapSearch.new

      result = ldap_search.email_query('dfahlkfhdal')

      expect(result).to eq []
    end
  end

  describe '#info_query' do
    it 'should return my name' do
      ldap_search = LdapSearch.new

      result = ldap_search.info_query('holt')

      expect(result).to include ['William Holt', 'holtw@musc.edu']
    end

    it 'should return my email' do
      ldap_search = LdapSearch.new

      result = ldap_search.info_query('holt')

      expect(result).to include ['William Holt', 'holtw@musc.edu']
    end

    it 'should not return my name' do
      ldap_search = LdapSearch.new

      result = ldap_search.info_query('cates')

      expect(result).not_to include ['William Holt', 'holtw@musc.edu']
    end

    it 'should return Jays name' do
      ldap_search = LdapSearch.new

      result = ldap_search.info_query('cates')

      expect(result).to include ['Andrew Cates', 'catesa@musc.edu']
    end
  end

  describe '#name_query' do
    it 'should return my name' do
      ldap_search = LdapSearch.new

      result = ldap_search.name_query('wih205')

      expect(result).to eq 'William Holt'
    end
  end
end


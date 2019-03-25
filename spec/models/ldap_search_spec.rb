require 'rails_helper'

describe LdapSearch do

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
end

